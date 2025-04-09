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

SELECT
	CASE
		WHEN date_of_birth > '2014-09-01' THEN '1'
		WHEN date_of_birth BETWEEN '2013-09-01' AND '2014-08-31' THEN '2'
		WHEN date_of_birth BETWEEN '2012-09-01' AND '2013-08-31' THEN '3'
		ELSE '4'
	END AS academic_year,
	(pupil_last_name || ', ' || pupil_first_name) AS pupil_name,
	CASE
		WHEN parental_contact = 1 THEN (pupil_last_name || ', ' || parental_contact_name_1)
		WHEN parental_contact = 2 THEN (pupil_last_name || ', ' || parental_contact_name_2)	
	END AS parental_contact_full_name,
	CASE
		WHEN parental_contact = 1 THEN (parental_contact_name_1 || '.' || pupil_last_name || '@' || preferred_contact_employer || '.com' )
		WHEN parental_contact = 2 THEN (parental_contact_name_2 || '.' || pupil_last_name || '@' || preferred_contact_employer || '.com' )	
	END AS parental_contact_email_address
FROM prep_school

