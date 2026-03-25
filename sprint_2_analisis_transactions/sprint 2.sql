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
SELECT COUNT(DISTINCT c.country)
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
SELECT t.id
  FROM transaction t 
 WHERE company_id IN (
					  SELECT id
					    FROM company
                       WHERE country = 'Germany'
					 );

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT id, 
	   company_name
  FROM company
 WHERE id IN (SELECT company_id
                FROM transaction
               WHERE amount > (
							   SELECT AVG(amount) AS media_total_transactions
								 FROM transaction
							  )
			 );

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id
  FROM company
 WHERE id NOT IN (
			      SELECT DISTINCT company_id
					FROM transaction
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
	   ROUND(AVG(num_trans.total_transactions),2) AS average_transactions
 FROM company c 
 JOIN (
	   SELECT company_id, 
			  COUNT(id) AS total_transactions
		 FROM transaction
		GROUP BY company_id
	  ) AS num_trans
   ON c.id = num_trans.company_id
GROUP BY c.country
ORDER BY average_transactions DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
-- per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
-- que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT t.id AS transaction_id_NI_competitors,
	   c.company_name AS NI_competitors
  FROM transaction t
  JOIN company c
    ON t.company_id = c.id
 WHERE c.company_name <> "Non Institute"
	   AND country = (
					  SELECT country
						FROM company
					   WHERE company_name = "Non Institute"
					  );
 
-- Mostra el llistat aplicant solament subconsultes.
SELECT t.id AS transaction_id_NI_competitors
  FROM transaction t
 WHERE company_id IN (
					   SELECT id
						 FROM company
						WHERE country = (
										 SELECT country
										   FROM company
										  WHERE company_name = "Non Institute"
										 )
							  AND company_name <> "Non Institute"
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
 WHERE amount BETWEEN 350 AND 400
	   AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
 ORDER BY amount DESC;


-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT company_id, 
	   COUNT(id) AS total_transactions,
  CASE
       WHEN COUNT(id) >= 400 THEN True
       WHEN COUNT(id) < 400 THEN False
   END AS 'More than 400'
  FROM transaction 
 GROUP BY company_id
 ORDER BY COUNT(id);