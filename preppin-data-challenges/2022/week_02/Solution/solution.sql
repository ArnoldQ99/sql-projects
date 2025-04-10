CREATE TABLE prep_school(
	id	INT,
	pupil_first_name	TEXT,
	pupil_last_name	TEXT,
	gender	TEXT,
	date_of_birth	DATE,
	parental_contact_name_1	TEXT,
	parental_contact_name_2	TEXT,
	preferred_contact_employer	TEXT,
	parental_contact	INT
);

SELECT * FROM prep_school;

-- Challenge Query

WITH cte AS(
	SELECT
		(pupil_first_name || ' ' || pupil_last_name) AS pupil_name,
		date_of_birth,
		CASE
			WHEN EXTRACT(YEAR FROM date_of_birth) = '2011' THEN (date_of_birth + INTERVAL '11 Years') :: DATE
			WHEN EXTRACT(YEAR FROM date_of_birth) = '2012' THEN (date_of_birth + INTERVAL '10 Years') :: DATE
			WHEN EXTRACT(YEAR FROM date_of_birth) = '2013' THEN (date_of_birth + INTERVAL '9 Years') :: DATE
			WHEN EXTRACT(YEAR FROM date_of_birth) = '2014' THEN (date_of_birth + INTERVAL '8 Years') :: DATE
			ELSE (date_of_birth + INTERVAL '7 Years') :: DATE
		END AS this_years_birthday
	FROM prep_school
),
cte2 AS(
	SELECT
		*,
		TO_CHAR(this_years_birthday, 'Month') AS Month,
		CASE
			WHEN TRIM((TO_CHAR(this_years_birthday, 'Day'))) IN ('Saturday','Sunday') THEN 'Friday'
			ELSE TRIM(TO_CHAR(this_years_birthday, 'Day'))
		END AS cake_needed_on
	FROM cte
),
agg AS( 
	SELECT 
		month,
		cake_needed_on,
		COUNT(*) As BDs_per_weekday_and_month
	FROM cte2
	GROUP BY 1,2
)
SELECT 
	c.*,
	agg.BDs_per_weekday_and_month
FROM cte2 AS c
JOIN agg 
ON agg.month = c.month AND agg.cake_needed_on = c.cake_needed_on
