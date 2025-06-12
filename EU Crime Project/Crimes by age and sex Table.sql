USE eu_crime;

-- Creating table for age and sex crime data
CREATE TABLE crime_age_sex(
	DATAFLOW VARCHAR(50), 
    LAST_UPDATE DATETIME, 
    freq CHAR(6), 
    age VARCHAR(10), 
    sex VARCHAR(10), 
    unit VARCHAR(35),
    geo VARCHAR(35), 
    TIME_PERIOD YEAR, 
    OBS_VALUE FLOAT(8, 2),
    OBS_FLAG CHAR(1), 
    CONF_STATUS CHAR(1)
);

-- Loading in data from CSV file
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Prisoners by age and sex.csv"
INTO TABLE crime_age_sex
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Modifying table (i.e. dropping columns, changing column names, updating values, etc.)

ALTER TABLE crime_age_sex
DROP DATAFLOW, 
DROP LAST_UPDATE, 
DROP freq, 
DROP OBS_FLAG, 
DROP CONF_STATUS;

ALTER TABLE crime_age_sex
RENAME COLUMN age TO lifestage, 
RENAME COLUMN unit TO unit_of_measure, 
RENAME COLUMN geo TO country, 
RENAME COLUMN TIME_PERIOD TO recorded_year, 
RENAME COLUMN OBS_VALUE TO recorded_value;

ALTER TABLE crime_age_sex
ADD COLUMN ID INT AUTO_INCREMENT, 
ADD PRIMARY KEY(ID, lifestage, sex, unit_of_measure, country, recorded_year);

ALTER TABLE crime_age_sex
MODIFY COLUMN ID INT AUTO_INCREMENT FIRST;

UPDATE crime_age_sex
SET sex = 'F'
WHERE sex = 'Females';

UPDATE crime_age_sex
SET sex = 'M'
WHERE sex = 'Males';

DELETE FROM crime_age_sex 
WHERE
    lifestage = 'Total';
    
DELETE FROM crime_age_sex 
WHERE
    sex = 'Total';
