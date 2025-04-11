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

SELECT * FROM prep_school;

CREATE TABLE grades(
	student_id	INT,
	maths	INT,
	english	INT,
	spanish 	INT,
	science	INT,
	art	INT,
	history	INT,
	geography	INT
);

SELECT * FROM grades;


-- Challenge Query

WITH pivot AS(
	SELECT student_id, 'maths' AS subject, maths AS score FROM grades
	UNION ALL
	SELECT student_id, 'english' AS subject, english AS score FROM grades
	UNION ALL
	SELECT student_id, 'spanish' AS subject, spanish AS score FROM grades
	UNION ALL
	SELECT student_id, 'science' AS subject, science AS score FROM grades
	UNION ALL
	SELECT student_id, 'art' AS subject, art AS score FROM grades
	UNION ALL
	SELECT student_id, 'history' AS subject, history AS score FROM grades
	UNION ALL
	SELECT student_id, 'geography' AS subject, geography AS score FROM grades
),
average_scores AS(
	SELECT 
		student_id,
		gender,
		ROUND(AVG(score),1) AS student_avg_score
	FROM prep_school AS ps
	JOIN pivot AS p
	ON p.student_id = ps.id
	GROUP BY 1,2
),
passed_subs AS(
	SELECT 
		student_id,
		gender,
		SUM(CASE WHEN score > 75 THEN 1 END) AS passed_subjects
	FROM prep_school AS ps
	JOIN pivot AS p 
	ON p.student_id = ps.id
	GROUP BY 
	1,2
)
SELECT 
	a.student_id,
	a.gender,
	student_avg_score,
	passed_subjects
FROM average_scores AS a
JOIN passed_subs AS p
ON 
	a.student_id = p.student_id


	









