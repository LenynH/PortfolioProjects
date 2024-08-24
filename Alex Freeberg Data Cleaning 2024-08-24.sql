		-- Data Cleaning Project: Layoffs -- 

-- Creating the 'World Layoffs' Database --
CREATE DATABASE IF NOT EXISTS world_layoffs;

-- Preliminary check of Newly Imported Data -- 
USE	 world_layoffs;

SELECT *
FROM	
	layoffs;
    
-- Creating A Copy of 'layoffs' Table for Data Security --
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM	
	layoffs;
    
SELECT *
FROM	
	layoffs_staging;
    
-- Step 1: Removing Duplicates --
	
    -- Using ROW_NUMBER to locate them
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num 
FROM	
	layoffs_staging;
    
WITH duplicates_cte as (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num 
FROM	
	layoffs_staging)
SELECT *
FROM
	duplicates_cte
WHERE
	row_num > 1;
    
    -- Examine Results; Found that the results given are not actually complete duplicates.
SELECT 
    *
FROM
    layoffs_staging
WHERE
    company = 'Oda';

	-- Amend Code and Try Again
WITH duplicates_cte as (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, 
								location, 
                                industry, 
                                total_laid_off, 
                                percentage_laid_off, 
                                'date', 
                                stage, 
                                country, 
                                funds_raised_millions) as row_num 
FROM	
	layoffs_staging)
SELECT *
FROM
	duplicates_cte
WHERE
	row_num > 1;
    
SELECT 
    *
FROM
    layoffs_staging
WHERE
    company = 'Casper';
	
    -- Creating Another Table to Help Delete The Duplicates    
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
INSERT INTO layoffs_staging_2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, 
								location, 
                                industry, 
                                total_laid_off, 
                                percentage_laid_off, 
                                'date', 
                                stage, 
                                country, 
                                funds_raised_millions) as row_num 
FROM	
	layoffs_staging;    
    
	-- Examine New Table
SELECT 
    *
FROM
    layoffs_staging_2
WHERE 
	row_num > 1;
    
    -- Delete Duplicates
DELETE
FROM
    layoffs_staging_2
WHERE 
	row_num > 1;
    
    -- Examine Final Result
SELECT 
    *
FROM
    layoffs_staging_2
WHERE 
	row_num > 1;
    
SELECT 
    *
FROM
    layoffs_staging_2;

-- Step 2: Standardize the Data --
	-- Trimming the 'company' column
SELECT 
    company, TRIM(company)
FROM
    layoffs_staging_2;
    
UPDATE layoffs_staging_2
SET company = TRIM(company);

	-- Cleaning the 'industry' column
	----- Examining the Column
SELECT DISTINCT
    industry
FROM
    layoffs_staging_2
ORDER BY 1;

SELECT DISTINCT
    *
FROM
    layoffs_staging_2
WHERE
    industry LIKE 'Crypto%';
    
	----- Standardizing the 'Crypto' related industries
UPDATE layoffs_staging_2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';
    
SELECT DISTINCT
    industry
FROM
    layoffs_staging_2
ORDER BY 1;
	
    -- Cleaning the 'location' column
    ----- NO Cleaning Performed (however some actually needed; Return to later)
SELECT DISTINCT
    location
FROM
    layoffs_staging_2
ORDER BY 1;

	-- Cleaning the 'country' column
	----- Examining Column and Looking for Outliers 
SELECT DISTINCT
    country
FROM
    layoffs_staging_2
ORDER BY 1;

SELECT 
    country, COUNT(country)
FROM
    layoffs_staging_2
WHERE
    country LIKE 'United States%'
GROUP BY country;

SELECT DISTINCT
    country, TRIM(TRAILING '.' FROM country)
FROM
    layoffs_staging_2
ORDER BY 1;
	
    ----- Updating the Data with Correct Info
UPDATE layoffs_staging_2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';
    
	----- Examining Results
SELECT DISTINCT
    country
FROM
    layoffs_staging_2
ORDER BY 1;

	-- Cleaning the 'date' Column
	----- Formatting the data in the column
SELECT 
    `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM
    layoffs_staging_2;
SELECT 
    `date`
FROM
    layoffs_staging_2;
    
UPDATE layoffs_staging_2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
   
   ----- Altering the Actual 'date' Column to hold the correct datat type
ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- Step 3: Examine the NULL/Blank Values --
	-- Examining the 'total_laid_off' column
	----- Examine Table as a Whole
SELECT 
    *
FROM
    layoffs_staging_2;
    
    ----- Examine NULL Values in 'total...' column; Large amount of nulls 
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    total_laid_off IS NULL;
    
    ----- Examine the data where both '...laid_off' columns contain nulls    
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

	----- Backtrack to industry column and view NULLS here
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    industry IS NULL OR industry = '';
    
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    company = 'Airbnb';

	----- Using JOINS to compare the table to itself and find similar datapoints with and without NULLS
SELECT 
    t1.company, t1.industry, t2.industry
FROM
    layoffs_staging_2 t1
        JOIN
    layoffs_staging_2 t2 ON t1.company = t2.company
        AND t1.location = t2.location
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;

	----- Updating the 'industry' column blanks 
UPDATE layoffs_staging_2 
SET 
    industry = NULL
WHERE
    industry = '';    
    
UPDATE layoffs_staging_2 t1
        JOIN
    layoffs_staging_2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;
        
	----- Check Results: 
		-- One industry left NULL since there was no other reference datapoint to help fill info
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    industry IS NULL OR industry = '';
    
        
-- Step 4: Removal of Unnecessary Rows/Columns -- 
	-- 'total...' and percentage...' don't have enough reference info to be fixed so time to delete
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;
        
DELETE FROM layoffs_staging_2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
    
	-- Other columns that need removal: 'row_num'
SELECT 
    *
FROM
    layoffs_staging_2;
    
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;