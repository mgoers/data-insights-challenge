-- CREATE TABLE FROM LOCAL CSV
CREATE FILE FORMAT CSV_FILE 
			TYPE = CSV
			SKIP_HEADER = 1
			EMPTY_FIELD_AS_NULL = TRUE
			SKIP_BLANK_LINES = TRUE
			NULL_IF = ('\\N', 'NULL', 'NUL', '', '""')
;

-- ALTER FILE FORMAT CSV_FILE SET NULL_IF = ('\\N', 'NULL', 'NUL', '', '""')
;

--DROP STAGE DATA_STAGE_MLB
;

CREATE STAGE DATA_STAGE_MLB
     FILE_FORMAT = CSV_FILE	
;
 
PUT file:////Users/matthias/Data/mlb_players.csv @DATA_STAGE_MLB
;


--DROP TABLE  MLB_PLAYERS
;

CREATE TABLE PUBLIC.MLB_PLAYERS (
    Name VARCHAR(256), 
    Team VARCHAR(256),
    Position VARCHAR(256),
    Height SMALLINT,
    Weight SMALLINT,
    Age DOUBLE
-- DATETIME
-- FLOAT   
    )
;

   
COPY INTO PUBLIC.MLB_PLAYERS FROM @DATA_STAGE_MLB
		ON_ERROR = CONTINUE
;


SELECT *
FROM PUBLIC.MLB_PLAYERS 
LIMIT 100
;