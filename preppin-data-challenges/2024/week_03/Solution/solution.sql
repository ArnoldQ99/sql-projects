CREATE TABLE q1_targets(
	month INT,
	class TEXT,
	target INT
);

SELECT * FROM q1_targets;

CREATE TABLE q2_targets(
	month INT,
	class TEXT,
	target INT
);

CREATE TABLE q3_targets(
	month INT,
	class TEXT,
	target INT
);

CREATE TABLE q4_targets(
	month INT,
	class TEXT,
	target INT
);

-- Challenge Query

WITH union_data AS(
	SELECT * FROM flow_card
	UNION ALL
	SELECT * FROM no_flow_card
	),
union_targets AS(
	SELECT * FROM q1_targets
	UNION ALL
	SELECT * FROM q2_targets
	UNION ALL
	SELECT * FROM q3_targets
	UNION ALL
	SELECT * FROM q4_targets
	),
cte AS(
	SELECT
		EXTRACT(month FROM date) AS Date,
		CASE
			WHEN flight_class = 'Economy' THEN 'FC'
			WHEN flight_class = 'First Class' THEN 'E'
			WHEN flight_class = 'Business Class' THEN 'PE'
			WHEN flight_class = 'Premium Economy' THEN 'BC'
		END AS Class,
		SUM(price) AS Price
	FROM union_data
	GROUP BY 1,2
	)
	SELECT
	(price - target) AS difference_to_target,
	cte.date,
	cte.price,
	cte.class,
	target
	FROM cte
	LEFT JOIN union_targets AS ut
	ON cte.date = ut.month AND cte.class = ut.class
