-- EDA OF THE DATA

SELECT *
FROM layoffs.layoffs_staging2;

-- Looking at maximum values to see how big these layoffs were
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs.layoffs_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs.layoffs_staging2
WHERE percentage_laid_off = 1.0
ORDER BY funds_raised DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs.layoffs_staging2;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Industries with the most Total Layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Countries with the most Total Layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Year with the most Total Layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Average Layoffs by the companies
SELECT company, AVG(percentage_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Layoffs Per Month
SELECT SUBSTRING(`date`, 1, 7) AS `Y-M`, SUM(total_laid_off) 
FROM layoffs.layoffs_staging2
GROUP BY `Y-M`
ORDER BY 1 ASC;

-- Rolling Total of Layoffs Per Month
WITH Rolling_Total AS(
SELECT SUBSTRING(`date`, 1, 7) AS `Y-M`, SUM(total_laid_off) AS total_laidoffs
FROM layoffs.layoffs_staging2
GROUP BY `Y-M`
ORDER BY 1 ASC)
SELECT `Y-M`, total_laidoffs, SUM(total_laidoffs) OVER(ORDER BY `Y-M`) AS rolling_total
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Companies yearly Total Layoffs with ranking <= 5
WITH Company_Year (company, years, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;