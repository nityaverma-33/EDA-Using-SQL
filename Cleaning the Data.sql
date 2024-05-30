-- Using the Layoffs dataset that we have imported
USE layoffs;

-- Selecting the Layoffs table
SELECT *
FROM layoffs;

-- CLEANING THE DATA

-- Creating new table which we'll use for data cleaning purpose
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Checking for duplicates by creating row_num
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

-- Checking where we have row_num > 2 (where we have the duplicates)
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- Deleting the duplicates
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging)
SELECT *                        -- delete won't work here, hence we'll create a new table
FROM duplicate_cte
WHERE row_num > 1;

-- Creating new table for deleting the duplicates 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

-- Deleting the rows where row_num > 2 (deleting duplicates)
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing the data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT country, TRIM(country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(country);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT `date`
FROM layoffs_staging2;

-- Converting the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Checking the data where we have 'percentage_laid_off' blank or null
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
OR percentage_laid_off = '' ;

-- Deleting the data where we have percentage_laid_off blank or null
DELETE
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
OR percentage_laid_off = '' ;

-- Cheking for the industries having blank or null values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Cheking the data for company named 'Appsmith'
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Appsmith';
 
-- Dropping of the column row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;