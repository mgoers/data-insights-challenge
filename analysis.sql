-- I WOULD ACTUALLY UPDATE THE REGULAR CUSTOMERS_CURRENT TABLE HERE BUT IT'S CLEARER TO DEMO IT
CREATE TABLE PUBLIC.CUSTOMERS_CURRENT_UPDATED AS (SELECT * FROM PUBLIC.CUSTOMERS_CURRENT)
;


SELECT * FROM CUSTOMERS_CURRENT_UPDATED
ORDER BY 1 ASC
;

--CUSTOMER_ID|UPDATE_DATE|LOCATION|
-------------+-----------+--------+
--        101|01.01.2000 |Berlin  |
--        102|02.01.2000 |London  |
--        103|03.01.2000 |Moscow  |
--        104|04.01.2000 |Paris   |
        

-- CREATE A TEMP TABLE TO IDENTIFY THE ROWS WHICH MUST BE UPDATED
CREATE TEMPORARY TABLE TMP_CUSTOMERS_CURRENT_UPDATED AS (
	SELECT 
		CUSTOMERS_UPDATES.CUSTOMER_ID,
		CUSTOMERS_UPDATES.UPDATE_DATE,
		CUSTOMERS_UPDATES.LOCATION,
		CUSTOMERS_UPDATES.UPDATE_FLAG,
		RANK() OVER (PARTITION BY CUSTOMERS_UPDATES.CUSTOMER_ID ORDER BY CUSTOMERS_UPDATES.UPDATE_DATE DESC) AS UPDATE_RANK
	FROM CUSTOMERS_UPDATES
		LEFT JOIN CUSTOMERS_CURRENT_UPDATED 
		ON CUSTOMERS_CURRENT_UPDATED.CUSTOMER_ID = CUSTOMERS_UPDATES.CUSTOMER_ID
	WHERE TO_DATE(CUSTOMERS_UPDATES.UPDATE_DATE, 'DD.MM.YYYY') > COALESCE(TO_DATE(CUSTOMERS_CURRENT_UPDATED.UPDATE_DATE, 'DD.MM.YYYY'),'1970-01-01')
	)
;

-- DELETE THE CUSTOMER_ID FROM TABLE WHICH IS UPDATES USING TMP_CUSTOMERS_CURRENT_UPDATED ID LIST
DELETE FROM CUSTOMERS_CURRENT_UPDATED WHERE CUSTOMER_ID IN 
	(
	SELECT DISTINCT 
	CUSTOMER_ID
	FROM TMP_CUSTOMERS_CURRENT_UPDATED
	)
;

-- INSERT BACK THE CUSTOMERS WHICH MUST BE UPDATED IDENTIFIED BY RANK OF LATEST UPDATE AND NON DELETIONS
INSERT INTO CUSTOMERS_CURRENT_UPDATED(CUSTOMER_ID, UPDATE_DATE, LOCATION)
	SELECT 
		CUSTOMER_ID,
		UPDATE_DATE,
		LOCATION
	FROM TMP_CUSTOMERS_CURRENT_UPDATED
	WHERE UPDATE_RANK = 1 AND UPDATE_FLAG != 'D'

-- I READ IN https://docs.snowflake.com/en/sql-reference/sql/insert THAT THERE IS AN UPDATE OVERWRITE WHICH MIGHT BE DOING BOTH AT ONCE
-- BUT I DIDN'T HAVE ENOUGH TIME TO TRY IT IN THE SCOPE OF THIS TEST	
;


-- REMOVE TEMP TABLE WHICH ONLY IDENTIFIED THE UPDATES
DROP TABLE IF EXISTS TMP_CUSTOMERS_CURRENT_UPDATED
;


SELECT * FROM CUSTOMERS_CURRENT_UPDATED
ORDER BY 1 ASC

-- CUSTOMER_ID|UPDATE_DATE|LOCATION|
-------------+-----------+--------+
--        101|01.01.2000 |Berlin  |
--        102|05.02.2018 |Istanbul|
--        104|04.01.2000 |Paris   |
--        105|05.02.2018 |Vienna  |