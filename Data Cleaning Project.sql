--- Data Cleaning 


select *
from world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove any columns


-- To proserve the raw data set will work on a duplicated verision
create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

-- Removing Dulicates

select *,
row_number() over(
partition by company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1; 

select *
from layoffs_staging
where company = 'Ola';




CREATE TABLE `layoffs_staging2` (
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

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1;

-- standardizing data

select company, trim(company)
from layoffs_staging2;

Update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
Order by 1;

-- setting all names for crypto to be uniform
select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select *
from layoffs_staging2;

select distinct country
from layoffs_staging2
order by 1;

-- Fixing name error with United states that had a period at the end
select *
from layoffs_staging2
where country like 'United States%';

update layoffs_staging2
set country = 'United States'
where country like 'United States%';

-- Fixing the data data type

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

-- above only change the format, now we change the colum to a date rather than text

alter table layoffs_staging2
modify column `date` DATE;

select *
from layoffs_staging2
order by 1;

-- 3. Null Values or blank values

select *
from layoffs_staging2
where total_laid_off is null;

-- might be usless rows that are deleted in step 4
select *
from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';


-- Great use of join
Select *
From layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- did not work so we will try setting blanks to nulls
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
Set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

Update layoffs_staging2
set industry = null
where industry = '';


-- Need to be confident when it comes to deleting data

select *
from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

select *
from layoffs_staging2;

-- Dropping a colunm

alter table layoffs_staging2
drop column row_num;