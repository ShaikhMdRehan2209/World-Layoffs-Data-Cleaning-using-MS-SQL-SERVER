SELECT *
FROM PortfolioProject.dbo.layoffs;

-----------------------------------------------
-- CREATING A COPY OF DATASET
SELECT * INTO layoffs_staging 
FROM PortfolioProject.dbo.layoffs;

SELECT *
FROM PortfolioProject.dbo.layoffs_staging;

-----------------------------------------------
-- REMOVING DUPLICATES (IF ANY)
WITH duplicate_cte AS (
	SELECT *, ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions ORDER BY (SELECT NULL)
	) AS row_num
	FROM PortfolioProject.dbo.layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num>1;

-----------------------------------------------
-- STANDARDIZING DATA

--1
SELECT company, TRIM(company)
FROM PortfolioProject.dbo.layoffs_staging;

UPDATE PortfolioProject.dbo.layoffs_staging
SET company = TRIM(company);

--2
SELECT DISTINCT industry
FROM PortfolioProject.dbo.layoffs_staging
ORDER BY 1;

SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE industry LIKE 'Crypto %';

SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE industry LIKE 'CryptoCurrency';

UPDATE PortfolioProject.dbo.layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto %' OR industry = 'CryptoCurrency';

--3
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM PortfolioProject.dbo.layoffs_staging
ORDER BY 1;

SELECT * 
FROM PortfolioProject.dbo.layoffs_staging
WHERE country = 'United States.';

UPDATE PortfolioProject.dbo.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country = 'United States.';

--4
SELECT [date], TRY_CONVERT(DATE, [date], 101) 
FROM PortfolioProject.dbo.layoffs_staging;

UPDATE PortfolioProject.dbo.layoffs_staging
SET [date] = TRY_CONVERT(DATE, [date], 101);

ALTER TABLE PortfolioProject.dbo.layoffs_staging
ALTER COLUMN [date] DATE;

SELECT *
FROM PortfolioProject.dbo.layoffs_staging;

-----------------------------------------------
-- FIXING NULLS AND MISSING VALUES

SELECT DISTINCT industry
FROM PortfolioProject.dbo.layoffs_staging;

SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE industry IS NULL OR industry = '';

SELECT *
FROM PortfolioProject.dbo.layoffs_staging t1
JOIN PortfolioProject.dbo.layoffs_staging t2
	ON t1.company=t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE PortfolioProject.dbo.layoffs_staging
SET industry = NULL
WHERE industry = '';

UPDATE t1
SET t1.industry = t2.industry
FROM PortfolioProject.dbo.layoffs_staging t1
JOIN PortfolioProject.dbo.layoffs_staging t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE industry = 'NULL' OR industry = '';

SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE company LIKE 'Bally%';

-----------------------------------------------
-- REMOVING UNWANTED ROWS 
SELECT *
FROM PortfolioProject.dbo.layoffs_staging
WHERE total_laid_off = 'NULL' AND percentage_laid_off = 'NULL';

DELETE
FROM PortfolioProject.dbo.layoffs_staging
WHERE total_laid_off = 'NULL' AND percentage_laid_off = 'NULL';

SELECT *
FROM PortfolioProject.dbo.layoffs_staging;

-- Copy all rows from layoffs_staging to layoffs
INSERT INTO PortfolioProject.dbo.layoffs
SELECT * 
FROM PortfolioProject.dbo.layoffs_staging;

SELECT *
FROM PortfolioProject.dbo.layoffs;
