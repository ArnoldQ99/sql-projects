-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p1;

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
	transactions_id INT PRIMARY KEY, 
	sale_date	DATE,
	sale_time	TIME,
	customer_id	INT,
	gender	VARCHAR(15),
	age	INT,
	category	VARCHAR(15),
	quantiy	INT,
	price_per_unit	FLOAT,
	cogs	FLOAT,
	total_sale FLOAT
);

SELECT * FROM retail_sales
LIMIT 10;

SELECT 
	COUNT(*)
FROM retail_sales;

-- Data Cleaning
SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL 
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR 
	category IS NULL
	OR
	quantiy IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
	
--
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL 
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR 
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

-- Data Exploration

-- How many sales do we have?
SELECT 
	COUNT(*) AS total_sales
FROM retail_sales;

-- How many unique customers do we have?
SELECT
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- How many distinct categories do we have?
SELECT
	COUNT(DISTINCT category) AS unique_categories
FROM retail_sales;


-- Data analysis & business key problems and answers

-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'.

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2. Write a SQL query to retrieve all transactions where category is 'Clothing' and the quantity sold is at least 4 in the month of Nov-22.

SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND quantity >= 4
	
-- Q3. Write a SQL query to calculate the total sales for each category.

SELECT
	category,
	SUM(total_sale) AS total_sales,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

--Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
	ROUND(AVG(age),2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5. Write a SQL query to find all transactions where the total sales is greater than 1000.

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q6. Write  a SQL query to find the total number of transactions made by each gender in each category.

SELECT
	gender, 
	category,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY 
	gender,
	category;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out the best selling month in each year.

WITH table1 as(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) as avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY 1,2
	ORDER BY 1 ASC, 3 DESC
)
SELECT * 
FROM table1
WHERE rank = 1;

-- Q8. Write a SQL query to find the top 5 custoemrs based on the highest total sales.

SELECT
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

--Q9. Write a SQL query to find the number of unique customers who purchased items from each category

SELECT
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

--Q10. Write a SQL query to create each shift and a number of orders. (e.g morning < 12, afternoon between 12 and 17, evening >17).

SELECT
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY shift

-- END OF PROJECT P1.
