-- Netflix Project

-- Creating Table
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

-- Business Problems & Solutions

-- 1. Count the Number of Movies vs TV Shows

SELECT
	type, 
	COUNT(*) AS total
FROM netflix
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows

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

-- 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT 
	*
FROM netflix
WHERE 
	release_year = 2020
	AND
	type = 'Movie'
	;
	
	
-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
	TRIM( UNNEST (STRING_TO_ARRAY(country, ',') ) ) AS new_country,
	COUNT(*) AS total
FROM netflix
GROUP BY new_country
ORDER BY total DESC
LIMIT 5;


-- 5. Identify the Longest Movie

SELECT 
	title,
	SPLIT_PART(duration, ' ', 1) :: integer AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC
LIMIT 1;


-- 6. Find Content Added in the Last 5 Years

SELECT 
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

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

-- 8. List All TV Shows with More Than 5 Seasons

SELECT 
	title
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: integer > 5
	;
	
-- 9. Count the Number of Content Items in Each Genre

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


-- 10. Find each year and the average numbers of content release in India on netflix.

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

-- 11. List All Movies that are Documentaries

SELECT 
	*
FROM netflix 
WHERE 
	type = 'Movie'
	AND
	listed_in like '%Documentaries%'
	
-- 12. Find All Content Without a Director

SELECT 
	*
FROM netflix
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT 
	COUNT(*)
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

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


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

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
