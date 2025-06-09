-- Initial Database Creation
CREATE DATABASE eu_crime;

USE eu_crime;

-- Creating the first table
CREATE TABLE crime_1998_2007 (
	DATAFLOW VARCHAR(20),
    LAST_UPDATE DATETIME, 
    freq CHAR(6), 
    unit CHAR(6), 
    iccs VARCHAR(250), 
    geo VARCHAR(50),
    TIME_PERIOD YEAR, 
    OBS_VALUE SMALLINT UNSIGNED, 
    OBS_FLAG VARCHAR(50) DEFAULT NULL,
    CONF_STATUS VARCHAR(50) DEFAULT NULL
);

ALTER TABLE crime_1998_2007
MODIFY COLUMN OBS_VALUE INT UNSIGNED;

-- Checking file upload location for MySQL
SELECT @@secure_file_priv;

-- Loading in CSV file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Recorded Crimes 1998-2007.csv'
INTO TABLE crime_1998_2007
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Adjusting the table to show only necessary information
ALTER TABLE crime_1998_2007 
DROP COLUMN LAST_UPDATE, 
DROP COLUMN OBS_FLAG, 
DROP COLUMN CONF_STATUS, 
DROP COLUMN DATAFLOW;

ALTER TABLE crime_1998_2007
DROP DATAFLOW;

ALTER TABLE crime_1998_2007
ADD COLUMN ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- Changing table name due to misrepresentation of data
RENAME TABLE crime_1998_2007 TO crime_93_to_07;

-- Removal of more redundant data
ALTER TABLE crime_93_to_07
DROP freq,
DROP unit;

DELETE FROM crime_93_to_07
WHERE crime = 'Total';
 
-- Renaming Columns for Clarity
ALTER TABLE crime_93_to_07 
RENAME COLUMN iccs TO crime, 
RENAME COLUMN geo TO country, 
RENAME COLUMN TIME_PERIOD TO recorded_year, 
RENAME COLUMN OBS_VALUE TO count;

-- Removal of Duplicate Values


    



    
