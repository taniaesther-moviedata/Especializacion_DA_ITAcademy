/*Este sprint simula una situación empresarial en la que tendrás que realizar diversas manipulaciones en las tablas de una base de datos. 
Además, trabajarás con índices y vistas para optimizar las consultas y organizar la información.

Continuarás trabajando con la base de datos que contiene información de un marketplace, un entorno similar a Amazon donde varias empresas 
venden sus productos a través de un canal online. En esta actividad comenzarás a trabajar con datos relacionados con tarjetas de crédito.

Agregue las tablas al modelo según corresponda:

Nivel 1: tabla "credit_card"
Nivel 3: tabla de "usuarios"
*/

/*Nivel 1
Ejercicio 1
Su tarea es diseñar y crear una tabla llamada “credit_card” que almacene detalles cruciales sobre las tarjetas de crédito. 
La nueva tabla debe poder identificar de forma única cada tarjeta y establecer una relación adecuada con las otras 
dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que ingrese la información en el documento llamado 
dades_introduir_credit. Recuerda mostrar el diagrama y hacer una breve descripción del mismo.
*/
USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY, 
	iban VARCHAR(50), 
	pan VARCHAR(20), 
	pin VARCHAR(4), 
	cvv VARCHAR(3), 
	expiring_date VARCHAR(10)
    );
    
-- Cargamos los datos desde datos_introducir_sprint3_credit

-- Creamos la foreign key    
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

-- Una vez cargados, cambio el formato de expiring_date y los datos que contiene para tener la información en formato DATE
ALTER TABLE credit_card
ADD COLUMN expiring_date_2 DATE;

UPDATE credit_card
SET expiring_date_2 = str_to_date(expiring_date,'%m/%d/%y');

ALTER TABLE credit_card
DROP COLUMN expiring_date,
CHANGE COLUMN expiring_date_2 expiring_date DATE;

/*Ejercicio 2
El Departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a la tarjeta de crédito con ID CcU-2938. 
La información que se mostrará para este registro es: TR323456312213576817699999. Recuerde demostrar que el cambio se realizó.
*/
-- Revisamos el registro original
SELECT *
  FROM credit_card
 WHERE id = 'CcU-2938';

-- Realizamos los cambios en el registro
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- Comprobamos el resultado
SELECT *
  FROM credit_card
 WHERE id = 'CcU-2938';

/*Ejercicio 3
En la tabla "transacción" usted realiza una nueva transacción con la siguiente información:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
id_tarjeta_crédito	CcU-9999
mate_id	b-9999
id_usuario	9999
lat	829.999
longitud	-117.999
propietario	111.11
declinado	0
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

INSERT INTO transaction (id,credit_card_id,company_id,user_id,lat,longitude,amount,declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999','9999','829.999','-117.999','111.11','0');

/*Ejercicio 4
Desde recursos humanos se le solicita que elimine la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.
*/
-- Revisamos la tabla original
SELECT *
  FROM credit_card;
  
-- Realizamos la modificación
ALTER TABLE credit_card
DROP COLUMN pan;

-- Comprobamos el resultado
SELECT *
  FROM credit_card;
  
/*Nivel 2
Ejercicio 1
Elimine de la tabla de transacciones el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.
*/
-- Revisamos el registro original
SELECT *
  FROM transaction
 WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
 
-- Realizamos la modificación
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Comprobamos el resultado
SELECT *
  FROM transaction
 WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
 
/*Ejercicio 2
La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado una vista para proporcionar detalles clave sobre las empresas y sus transacciones. 
Necesitará crear una vista llamada VistaMarketing que contenga la siguiente información: 
Nombre de la empresa. Teléfono de contacto. País de residencia. Compra media realizada por cada empresa. 
Presenta la vista creada, ordenando datos desde mayor a menor compra promedio.
*/
CREATE VIEW VistaMarketing AS
SELECT t.company_id, 
	   c.company_name, 
	   c.phone, 
       c.country, 
       ROUND(AVG(t.amount),2) AS average_amount_sales
  FROM company c
  JOIN transaction t 
    ON c.id=t.company_id
 GROUP BY t.company_id
 ORDER BY average_amount_sales DESC;
 
SELECT *
  FROM VistaMarketing;
 
/*Ejercicio 3
Filtre la vista VistaMarketing para mostrar solo las empresas que tienen su país de residencia en "Alemania"
*/
SELECT *
  FROM VistaMarketing
 WHERE country = 'Germany';

/*Nivel 3
Ejercicio 1
La próxima semana tendrás una nueva reunión con responsables de marketing.
Un colega de su equipo hizo modificaciones en la base de datos, pero no recuerda cómo las hizo. 
Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:
(Diagrama en el archivo pdf)
En esta actividad es necesario describir el “paso a paso” de las tareas realizadas. 
Es importante hacer descripciones sencillas, sencillas y fáciles de entender. 
Para realizar esta actividad tendrás que trabajar con los archivos denominados "estructura_datos_user" y "datos_introducir_sprint3_user"

Recuerda seguir trabajando en el modelo y tablas con las que ya has trabajado hasta ahora.
*/
-- Dado el actual modelo se harán las siguientes modificaciones:
-- Eliminación de la vista VistaMarketing
DROP VIEW VistaMarketing;

-- Cambio de datatype en 2 columnas de credit_card
-- cvv VARCHAR(3) a INT
-- expiring_date DATE a VARCHAR(20) 
ALTER TABLE credit_card
MODIFY COLUMN cvv INT,
MODIFY COLUMN expiring_date VARCHAR(20);
-- En la misma tabla agregamos la columna fecha_actual
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- En la tabla company borramos la columna website
ALTER TABLE company
DROP COLUMN website;

-- Creamos la tabla user según estructura_datos_user
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
-- Cargamos los datos del archivo datos_introducir_sprint3_user
-- Comprobamos
SELECT *
  FROM user;
  
-- Antes realizamos cambios en la base de datos, 
-- comprobemos si hay algún user_id que no esté en nuestra nueva tabla
-- y la agregamos antes de crear la foreign key que la conecte con transaction
INSERT INTO user (id)
SELECT t.user_id
  FROM transaction t 
 WHERE NOT EXISTS(SELECT 1
					FROM user u
				   WHERE u.id=t.user_id);
                   
-- Por consistencia, creamos un trigger que automatice futuras adiciones
-- para insertar user_id si no existe
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

-- Para crear la foreign key necesitamos que la columna id de user sea de tipo INT
ALTER TABLE user
MODIFY COLUMN id INT;

-- Creamos la foreign key en transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) 
REFERENCES user(id); 

-- En la tabla user, cambiamos el nombre de la columna email a personal_email
ALTER TABLE user
RENAME COLUMN email TO personal_email;

-- Comprobamos el estado actual de la tabla user
SELECT * FROM user
ORDER BY id DESC;

-- Por último cambiamos el nombre de la tabla de user a data_user
ALTER TABLE user
RENAME TO data_user;
-- Comprobamos
SELECT *
  FROM data_user;

/*Ejercicio 2
La empresa también le pide que cree una vista llamada "InformeTecnico" que contenga la siguiente información:

ID de transacción
Nombre de usuario/aria
Apellido de usuario / aria
IBAN de la tarjeta de crédito utilizada.
Nombre de la empresa de la transacción realizada.
Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar el nombre de las columnas según sea necesario.
Muestra los resultados de la vista, ordene los resultados en orden descendente según la variable ID de transacción.
*/

CREATE VIEW InformeTecnico AS
SELECT t.id AS transaction_id,
	   d_u.name,
       d_u.surname,
       d_u.country AS user_country,
       c_c.iban,
       c.company_name,
       c.country AS company_country,
       t.declined
  FROM transaction t 
  JOIN data_user d_u
    ON t.user_id=d_u.id
  JOIN credit_card c_c
    ON t.credit_card_id=c_c.id
  JOIN company c
    ON t.company_id=c.id
 ORDER BY t.id DESC;
 
  SELECT *
   FROM InformeTecnico;