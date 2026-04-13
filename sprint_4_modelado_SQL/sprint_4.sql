/*Nivell 1

Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella 
que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
*/

CREATE DATABASE IF NOT EXISTS s4_transactions;
USE s4_transactions;

CREATE TABLE IF NOT EXISTS company (
    id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

/*Cargar datos en la tabla company
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(6),
    cvv VARCHAR(3),
    track1 VARCHAR(150),
    track2 VARCHAR(150),
    expiring_date VARCHAR(10)
);

/*Cargar datos en la tabla credit_card
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

# Cambiar el tipo de expiring_date a DATE
ALTER TABLE credit_card
ADD COLUMN expiring_date2 DATE;

UPDATE credit_card
set expiring_date2 = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE credit_card
DROP COLUMN expiring_date,
CHANGE COLUMN expiring_date2 expiring_date DATE;

CREATE TABLE IF NOT EXISTS product (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(50),
    weight DECIMAL(10,1),
    warehouse_id VARCHAR(150)
);

/*
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
INTO TABLE product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', '');
*/

CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

/*Cargar los datos desde american_users.csv
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\american_users.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Cargar los datos desde el archivo european_users.csv
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\european_users.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

#Hacer el setting de la columna region
ALTER TABLE user
ADD COLUMN region VARCHAR(100) NULL;

UPDATE user
SET region = CASE
    WHEN country IN ('United States', 'Canada') THEN 'America'
    ELSE 'Europe'
END;

#Cambiar el tipo de birth_date a DATE
ALTER TABLE user
ADD COLUMN birth_date2 DATE;

UPDATE user
SET birth_date2 = STR_TO_DATE(birth_date, '%b %d, %Y');

ALTER TABLE user
DROP COLUMN birth_date,
CHANGE COLUMN birth_date2 birth_date DATE;

ALTER TABLE user
MODIFY COLUMN birth_date DATE AFTER email;   

CREATE TABLE IF NOT EXISTS transaction (
    id VARCHAR(255) PRIMARY KEY,
    credit_card_id VARCHAR(15),
    company_id VARCHAR(15),
    timestamp TIMESTAMP,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT
);

/*cargar los datos desde el archivo transactions.csv
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- Crear la tabla intermedia entre transaction y product
CREATE TABLE IF NOT EXISTS transaction_product (
	id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  VARCHAR(255) NOT NULL,
    product_id INT NOT NULL
);

-- Cargar los datos 
INSERT INTO transaction_product (transaction_id, product_id)
SELECT t.id,
       j.product_id
  FROM transaction t
 CROSS JOIN JSON_TABLE(
                       CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),
                       '$[*]' COLUMNS (product_id INT PATH '$')
                      ) AS j; 

-- Comprobar datos en transaction_product y eliminar la columna product_ids
SELECT *
  FROM transaction_product tp
  LEFT JOIN product p 
    ON tp.product_id = p.id
 WHERE p.id IS NULL;

ALTER TABLE transaction
DROP COLUMN product_ids; 

ALTER TABLE transaction_product
ADD CONSTRAINT unique_t_p
UNIQUE (transaction_id, product_id); 

-- Crear las foreign keys
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_company
FOREIGN KEY (company_id) REFERENCES company(id); 
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) REFERENCES user(id); 
ALTER TABLE transaction_product
ADD CONSTRAINT fk_t_p_transaction
FOREIGN KEY (transaction_id) REFERENCES transaction(id); 
ALTER TABLE transaction_product
ADD CONSTRAINT fk_t_p_product
FOREIGN KEY (product_id) REFERENCES product(id); 

/*Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
*/
SELECT user.*, 
       num_t.num_transactions
  FROM user, (SELECT user_id, 
			         COUNT(id) AS num_transactions
			    FROM transaction
	           GROUP BY user_id
			  HAVING COUNT(id) > 80
	         ) AS num_t
 WHERE user.id=num_t.user_id;
  
/*Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
*/
SELECT c_c.iban, 
       ROUND(AVG(t.amount),2) AS average_amount_per_iban
  FROM transaction t 
  JOIN credit_card c_c
    ON t.credit_card_id=c_c.id
 WHERE EXISTS (SELECT 1
				 FROM company c 
				WHERE company_name = 'Donec Ltd'
					  AND t.company_id=c.id)
 GROUP BY c_c.iban
 ORDER BY average_amount_per_iban DESC;

/*Nivell 2
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:
*/
CREATE TABLE credit_card_status AS
SELECT credit_card_id,
	   CASE
			WHEN SUM(declined) = 3 THEN 'Inactive'
			ELSE 'Active'
	   END AS status
  FROM (SELECT *,
	           ROW_NUMBER() OVER (
						          PARTITION BY credit_card_id 
                                      ORDER BY timestamp DESC
						         ) AS ord
	    FROM transaction
       ) AS ranked
 WHERE ord <= 3
 GROUP BY credit_card_id;

/*Exercici 1
Quantes targetes estan actives?
*/
SELECT COUNT(credit_card_id) AS active_cards
  FROM credit_card_status
 WHERE status = 'Active';

/*Nivell 3
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv 
amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
*/

/*Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
*/
SELECT t_p.product_id, 
	   COUNT(DISTINCT t_p.transaction_id) AS num_sales
  FROM transaction_product t_p
  JOIN transaction t 
    ON t_p.transaction_id=t.id
 WHERE t.declined = 0
 GROUP BY t_p.product_id;