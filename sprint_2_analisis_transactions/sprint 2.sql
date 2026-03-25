USE transactions;
-- Nivell 1
-- Exercici 1
-- A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.
DESCRIBE company;
DESCRIBE transaction;

-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

-- Llistat dels països que estan generant vendes.
SELECT DISTINCT c.country
  FROM company c
  JOIN transaction t 
	ON c.id = t.company_id;

-- Des de quants països es generen les vendes.
SELECT COUNT(DISTINCT c.country) AS num_company_country
  FROM company c
  JOIN transaction t 
	ON c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name, ROUND(AVG(amount),2) AS media_ventas
  FROM company c
  JOIN transaction t
    ON c.id = t.company_id
 GROUP BY c.id
 ORDER BY media_ventas DESC
 LIMIT 1;

-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT t.id, 
	   t.company_id, 
       (SELECT c.company_name 
          FROM company c 
		 WHERE c.id=t.company_id) AS company
  FROM transaction t 
 WHERE EXISTS (
			   SELECT 1
                 FROM company c
				WHERE c.id = t.company_id
					  AND country = 'Germany'
			  );
              
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT c.id, 
	   c.company_name
  FROM company c 
 WHERE EXISTS (SELECT 1
                 FROM transaction t
                WHERE t.company_id = c.id
					  AND amount > (
									SELECT AVG(t.amount) AS media_total_transactions
								      FROM transaction t
							       )
			  );
              
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT c.id AS company_no_transactions
  FROM company c
 WHERE NOT EXISTS (
			       SELECT 1
					 FROM transaction t
					WHERE c.id=t.company_id
				  );

-- Nivell 2

-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp) AS day, 
	   SUM(amount) AS total_amount
  FROM transaction
 GROUP BY DATE(timestamp)
 ORDER BY total_amount DESC
 LIMIT 5;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT c.country, 
	   ROUND(AVG(amount),2) AS avg_sales
  FROM transaction t
  JOIN company c 
    ON t.company_id = c.id
 GROUP BY c.country
 ORDER BY avg_sales DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
-- per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
-- que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT t.id AS transaction_id_competitors,
	   c.company_name AS competitors
  FROM transaction t
  JOIN company c
    ON t.company_id = c.id
 WHERE country = (
				  SELECT country
					FROM company
				   WHERE company_name = "Non Institute"
				 );
               
-- Mostra el llistat aplicant solament subconsultes.
SELECT t.id AS transaction_id_competitors, 
	   t.company_id,
	   (SELECT c.company_name 
          FROM company c 
		 WHERE c.id=t.company_id) AS company
  FROM transaction t
 WHERE EXISTS (
				SELECT 1
				  FROM company c
				 WHERE c.id = t.company_id
					   AND country = (
									  SELECT c.country
									    FROM company c
								       WHERE company_name = "Non Institute"
								     )
			  );
-- Nivell 3
-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
-- amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, 
	   c.phone, 
       DATE(t.timestamp) AS date, 
       t.amount
  FROM company c
  JOIN transaction t 
    ON t.company_id = c.id
 WHERE t.amount BETWEEN 350 AND 400
	   AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
 ORDER BY amount DESC;


-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.
SELECT t.company_id, 
	   c.company_name,
	   COUNT(t.id) AS total_transactions,
	   CASE
		   WHEN COUNT(t.id) >= 400 THEN 'YES'
		   WHEN COUNT(t.id) < 400 THEN 'NO'
	   END AS 'More than 400'
  FROM transaction t
  JOIN company c 
    ON c.id=t.company_id
 GROUP BY t.company_id
 ORDER BY total_transactions;