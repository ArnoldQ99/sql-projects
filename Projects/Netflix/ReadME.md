# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/ArnoldQ99/sql-projects/blob/main/Projects/Netflix/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR,
	type	VARCHAR,
	title	VARCHAR,
	director	VARCHAR,
	casts	VARCHAR,
	country	VARCHAR,
	date_added	VARCHAR,
	release_year	INT,
	rating	VARCHAR,
	duration	VARCHAR,
	listed_in	VARCHAR,
	description	VARCHAR
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
	type, 
	COUNT(*) AS total
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCount AS(
	SELECT 
		type,
		rating,
		COUNT(*) AS total,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
	)
SELECT 
	type,
	rating
FROM RatingCount
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT 
	*
FROM netflix
WHERE 
	release_year = 2020
	AND
	type = 'Movie'
	;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	TRIM( UNNEST (STRING_TO_ARRAY(country, ',') ) ) AS new_country,
	COUNT(*) AS total
FROM netflix
GROUP BY new_country
ORDER BY total DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
	title,
	SPLIT_PART(duration, ' ', 1) :: integer AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
WITH unnested_director AS(
	SELECT 
		*,
		TRIM( UNNEST( STRING_TO_ARRAY(director, ',') )) AS director_name
	FROM netflix
	)
SELECT 
	*
FROM unnested_director
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
	title
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: integer > 5
	;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
WITH unnested_genres AS (
	SELECT 
		*,
		TRIM( UNNEST( STRING_TO_ARRAY(listed_in, ',') ) ) AS genre
	FROM netflix
	)
SELECT 
	genre,
	COUNT(*) AS total_content
FROM unnested_genres
GROUP BY genre;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 

```sql
WITH all_content AS(
	SELECT 
		release_year,
		COUNT(show_id) :: numeric AS all_release
	FROM netflix
	GROUP BY 1
	ORDER BY 1
),
india_content AS(
	SELECT
		release_year,
		COUNT(show_id) :: numeric As india_release
	FROM netflix
	WHERE country LIKE '%India%'
	GROUP BY 1
	ORDER BY 1
)
SELECT 
	ac.release_year,
	india_release,
	all_release,
	ROUND(( india_release / all_release ),2) AS avg_release_per_year
FROM india_content AS ic
JOIN all_content AS ac
ON ac.release_year = ic.release_year
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	*
FROM netflix 
WHERE 
	type = 'Movie'
	AND
	listed_in like '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT 
	*
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
	COUNT(*)
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
	TRIM(UNNEST(string_to_array(casts, ','))) AS actors,
	COUNT(*) AS films_appeared_in
FROM netflix
WHERE
	country LIKE '%India%'
	AND
	type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH grouped AS(
	SELECT 
		CASE
			WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Gore'
			ELSE 'Non-Gore'
			END AS category
	FROM netflix
	)
SELECT 
	category,
	COUNT(*) AS total
FROM grouped
GROUP BY category
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category. Ammended categories to be 'Gore' & 'Non-Gore'.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Arnold Quarcoo

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles.
