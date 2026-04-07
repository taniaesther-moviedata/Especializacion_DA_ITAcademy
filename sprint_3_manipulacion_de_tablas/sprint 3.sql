/*Nivell 1
Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". 
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
*/

USE transactions;
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY, 
	iban VARCHAR(50), 
	pan VARCHAR(20), 
	pin VARCHAR(4), 
	cvv INT, 
	expiring_date VARCHAR(10)
    );

SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id); 
SET FOREIGN_KEY_CHECKS = 1;

-- Cargo los datos desde dades_introduir_credit

-- Una vez cargados, cambio el formato de expiring_date y los datos que contiene para tener la información en formato DATE
ALTER TABLE credit_card
ADD COLUMN expiring_date_2 DATE;

UPDATE credit_card
SET expiring_date_2 = str_to_date(expiring_date,'%m/%d/%y');

ALTER TABLE credit_card
DROP COLUMN expiring_date,
CHANGE COLUMN expiring_date_2 expiring_date DATE;

/*Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
*/

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

/*Exercici 3
En la taula "transaction" ingressa una nova transacció amb la següent informació:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0
*/
-- Dado el modelo que tenemos con las foreign keys establecidas, necesitamos que el company_id exista en la tabla company
-- y el credit_card_id exista en la tabla credit_card

-- Trigger para insertar company_id si no existe
DELIMITER //
CREATE TRIGGER tg_company_before_transaction
BEFORE INSERT ON transaction
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM company WHERE id = NEW.company_id) THEN
        INSERT INTO company (id) VALUES (NEW.company_id);
    END IF;
END;
//
DELIMITER ;

-- Trigger para insertar credit_card_id si no existe
DELIMITER //
CREATE TRIGGER tg_credit_card_before_transaction
BEFORE INSERT ON transaction
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM credit_card WHERE id = NEW.credit_card_id) THEN
        INSERT INTO credit_card (id) VALUES (NEW.credit_card_id);
    END IF;
END;
//
DELIMITER ;

INSERT INTO tracompanynsaction (id,credit_card_id,company_id,user_id,lat,longitude,amount,declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999','9999','829.999','-117.999','111.11','0');

/*Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
*/

ALTER TABLE credit_card
DROP COLUMN pan;

/*Nivell 2
Exercici 1
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
*/

DELETE FROM transaction 
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

/*Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
*/

CREATE VIEW VistaMarketing AS
SELECT t.company_id, 
	   c.company_name, 
       c.phone, c.country, 
       ROUND(AVG(t.amount),2) AS average_amount_company
  FROM company c
  JOIN transaction t 
    ON c.id=t.company_id
 GROUP BY t.company_id
 ORDER BY average_amount_company DESC;
 
 SELECT *
   FROM VistaMarketing;

/*Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
*/

SELECT *
  FROM VistaMarketing
 WHERE country = "Germany";

/*Nivell 3
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:
Diagrama (ver la pagina del ejercicio)
En aquesta activitat, és necessari que descriguis el "pas a pas" de les tasques realitzades. 
És important realitzar descripcions senzilles, simples i fàcils de comprendre. 
Per a realitzar aquesta activitat hauràs de treballar amb els arxius denominats 
"estructura_dades_user" i "dades_introduir_user"
Recorda continuar treballant sobre el model i les taules amb les quals ja has treballat fins ara.
*/

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- Modifico los atributos de la columna id para que coincidan con la columna user_id de la tabla transaction
ALTER TABLE user
MODIFY COLUMN id INT;

SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) 
REFERENCES user(id); 
SET FOREIGN_KEY_CHECKS = 1; 

-- Cargo los datos desde el archivo dades_introduir_user

 -- Trigger para insertar user_id si no existe
DELIMITER //
CREATE TRIGGER tg_user_before_transaction
BEFORE INSERT ON transaction
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM user WHERE id = NEW.user_id) THEN
        INSERT INTO user (id) VALUES (NEW.user_id);
    END IF;
END;
//
DELIMITER ;

/*Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.
*/

CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaction, 
	   u.name AS user_name, 
       u.surname AS user_surname,
       c_c.iban, 
       c.company_name
  FROM transaction t
  JOIN company c
    ON t.company_id=c.id
  JOIN credit_card c_c
	ON t.credit_card_id=c_c.id
  JOIN user u 
	ON t.user_id=u.id;

SELECT * 
  FROM InformeTecnico
 ORDER BY id_transaction DESC;
