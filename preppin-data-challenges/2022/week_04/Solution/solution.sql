CREATE TABLE prep_school(
	id	INT,
	pupil_first_name	TEXT,
	pupil_last_name	TEXT,
	gender	TEXT,
	date_of_birth	DATE,
	parental_contact_name1	TEXT,
	parental_contact_name2	TEXT,
	preferred_contact_employer	TEXT,
	parental_contact	INT
);

SELECT * FROM prep_school

CREATE TABLE travel(
	student_id	INT,
	M	TEXT,
	Tu TEXT,
	W	TEXT,
	Th	TEXT,
	F	TEXT
);

SELECT * FROM travel;

-- Challenge Query

WITH pivot AS(
	SELECT student_id, m AS method_of_travel, 'm' AS weekday FROM travel
	UNION ALL
	SELECT student_id, tu AS method_of_travel, 'tu' AS weekday FROM travel
	UNION ALL
	SELECT student_id, w AS method_of_travel, 'w' AS weekday FROM travel
	UNION ALL
	SELECT student_id, th AS method_of_travel, 'th' AS weekday FROM travel
	UNION ALL
	SELECT student_id, f AS method_of_travel, 'f' AS weekday FROM travel
),
corrections AS(
	SELECT
		student_id,
		CASE
			WHEN method_of_travel IN ('WAlk', 'Waalk', 'Walkk', 'Wallk') THEN 'Walk'
			WHEN method_of_travel IN ('Carr') THEN 'Car'
			WHEN method_of_travel IN ('Helicopeter') THEN 'Helicopter'
			WHEN method_of_travel IN ('Bycycle') THEN 'Bicycle'
			WHEN method_of_travel IN ('Scoter', 'Scootr') THEN 'Scooter'
			ELSE method_of_travel
		END AS method_of_travel,
		weekday
	FROM pivot AS p
	JOIN prep_school AS ps
	ON p.student_id = ps.id
),
categories AS(
	SELECT
		CASE 
			WHEN method_of_travel IN ('Car','Helicopter','Aeroplane','Van') THEN 'Non-Sustainable'
			ELSE 'Sustainable'
		END AS sustainable,
		method_of_travel,
		weekday,
		1000 AS trips_per_day
	FROM corrections
),
groupings AS(
SELECT
	sustainable,
	method_of_travel,
	weekday,
	trips_per_day,
	COUNT(*) AS number_of_trips
FROM categories
GROUP BY 1,2,3,4
)
SELECT 
	*,
	ROUND((number_of_trips :: numeric / trips_per_day :: numeric),2) AS pct_trips_per_day
FROM groupings AS g


