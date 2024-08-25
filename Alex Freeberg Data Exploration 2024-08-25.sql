		-- Exploaratoy Data Analysis Project --
        
USE world_layoffs;

-- Exploring total_laid_off column in comparison to rest of data

SELECT 
    *
FROM
    layoffs_staging_2;
    
    ----- Highest number of employees laid off alongside the highest lay off percentage
SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM
    layoffs_staging_2;
    
    ----- Focusing in on the companies with a 100% layoff rate (means they completely shut down)
SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT 
    *
FROM
    layoffs_staging_2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

	----- Amount laid off per company 
SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

	----- Time range of layoffs
SELECT 
    MIN(date), MAX(date)
FROM
    layoffs_staging_2;
 
	----- Total layoffs by industry
SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

	----- Total layoffs by country
SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

	----- Total layoffs by date(split into years)
SELECT 
    YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

	----- total layoffs by stage
SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

	----- Rolling total of layoffs
SELECT 
    SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY `month`
HAVING `month` IS NOT NULL
ORDER BY 1;

with rolling_total as 
(
SELECT 
    SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) as total_off
FROM
    layoffs_staging_2
GROUP BY `month`
HAVING `month` IS NOT NULL
ORDER BY 1
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total_2
from rolling_total;

	----- Layoffs per company per year

SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT 
    company,
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging_2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year AS 
(
SELECT 
    company,
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging_2
GROUP BY company , YEAR(`date`)
), 
company_year_rank as 
(SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) as ranking
FROM company_year
HAVING `year` IS NOT NULL)
SELECT * 
FROM 
	company_year_rank
WHERE ranking <= 5;