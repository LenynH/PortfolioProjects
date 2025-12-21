USE eu_crime;

-- Creating Prisoners by Offence and Sex table
CREATE TABLE prisoners_offence_sex
(
	DATAFLOW VARCHAR(50),
    LAST_UPDATE DATETIME,
    freq CHAR(6),
    iccs VARCHAR(20),
    sex CHAR(7),
    unit VARCHAR(32),
    geo VARCHAR(33),
    TIME_PERIOD YEAR,
    OBS_VALUE DECIMAL(4,2),
    OBS_FLAG CHAR(1), 
    CONF_STATUS CHAR(1)
);

ALTER TABLE prisoners_offence_sex
MODIFY COLUMN OBS_VALUE DECIMAL (7,2);

-- Loading in CSV File 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Prisoners by Offence Cateogry and Sex.csv"
INTO TABLE prisoners_offence_sex
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Alterations (Adding/Deleting Unnecessary columns/data, Changing Column names, etc.)
ALTER TABLE prisoners_offence_sex
ADD COLUMN ID INT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE prisoners_offence_sex
DROP COLUMN DATAFLOW,
DROP COLUMN LAST_UPDATE,
DROP COLUMN freq,
DROP COLUMN OBS_FLAG,
DROP COLUMN CONF_STATUS;

DELETE FROM prisoners_offence_sex 
WHERE
    sex = 'Total';
    
ALTER TABLE prisoners_offence_sex
RENAME COLUMN  iccs TO offence,
RENAME COLUMN  unit TO unit_of_measure,
RENAME COLUMN  geo TO country_territory,
RENAME COLUMN  TIME_PERIOD TO recorded_year,
RENAME COLUMN  OBS_VALUE TO recorded_value;

SELECT 
    *
FROM
    prisoners_offence_sex;