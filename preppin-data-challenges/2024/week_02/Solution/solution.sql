CREATE VIEW median_price AS(
WITH union_data AS(
	SELECT * FROM flow_card
	UNION ALL
	SELECT * FROM no_flow_card
	),
quarter_group AS(
	SELECT 
		*,
		CASE
		WHEN date BETWEEN '2024-01-01' AND '2024-03-31' THEN '1'
		WHEN date BETWEEN '2024-04-01' AND '2024-06-30' THEN '2'
		WHEN date BETWEEN '2024-07-01' AND '2024-09-30' THEN '3'
		ELSE ' 4'
		END AS quarter 
	FROM union_data
	)
SELECT
	quarter,
	flow_card,
	flight_class,
	percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM quarter_group
GROUP BY quarter, flow_card, flight_class 
);

-- Flow 2

CREATE VIEW min_price AS(
WITH union_data AS(
	SELECT * FROM flow_card
	UNION ALL
	SELECT * FROM no_flow_card
	),
quarter_group AS(
	SELECT 
		*,
		CASE
		WHEN date BETWEEN '2024-01-01' AND '2024-03-31' THEN '1'
		WHEN date BETWEEN '2024-04-01' AND '2024-06-30' THEN '2'
		WHEN date BETWEEN '2024-07-01' AND '2024-09-30' THEN '3'
		ELSE ' 4'
		END AS quarter 
	FROM union_data
	)
SELECT
	quarter,
	flow_card,
	flight_class,
	MIN(price) AS min_price
FROM quarter_group
GROUP BY quarter, flow_card, flight_class 
);

-- Flow 3

CREATE VIEW max_price AS(
WITH union_data AS(
	SELECT * FROM flow_card
	UNION ALL
	SELECT * FROM no_flow_card
	),
quarter_group AS(
	SELECT 
		*,
		CASE
		WHEN date BETWEEN '2024-01-01' AND '2024-03-31' THEN '1'
		WHEN date BETWEEN '2024-04-01' AND '2024-06-30' THEN '2'
		WHEN date BETWEEN '2024-07-01' AND '2024-09-30' THEN '3'
		ELSE ' 4'
		END AS quarter 
	FROM union_data
	)
SELECT
	quarter,
	flow_card,
	flight_class,
	MAX(price) AS max_price
FROM quarter_group
GROUP BY quarter, flow_card, flight_class 
);

-- Final Output

WITH union_data AS(
SELECT 
	quarter,
	flow_card,
	MAX(CASE WHEN flight_class = 'Business Class' THEN min_price ELSE NULL END) AS Business_Class,
	MAX(CASE WHEN flight_class = 'Economy' THEN min_price ELSE NULL END) AS Economy,
	MAX(CASE WHEN flight_class = 'First Class' THEN min_price ELSE NULL END) AS First_Class,
	MAX(CASE WHEN flight_class = 'Premium Economy' THEN min_price ELSE NULL END) AS Premium_Economy
FROM min_price
GROUP BY quarter, flow_card

UNION ALL

SELECT 
	quarter,
	flow_card,
	MAX(CASE WHEN flight_class = 'Business Class' THEN median_price ELSE NULL END) AS Business_Class,
	MAX(CASE WHEN flight_class = 'Economy' THEN median_price ELSE NULL END) AS Economy,
	MAX(CASE WHEN flight_class = 'First Class' THEN median_price ELSE NULL END) AS First_Class,
	MAX(CASE WHEN flight_class = 'Premium Economy' THEN median_price ELSE NULL END) AS Premium_Economy
FROM median_price
GROUP BY quarter, flow_card

UNION ALL

SELECT 
	quarter,
	flow_card,
	MAX(CASE WHEN flight_class = 'Business Class' THEN max_price ELSE NULL END) AS Business_Class,
	MAX(CASE WHEN flight_class = 'Economy' THEN max_price ELSE NULL END) AS Economy,
	MAX(CASE WHEN flight_class = 'First Class' THEN max_price ELSE NULL END) AS First_Class,
	MAX(CASE WHEN flight_class = 'Premium Economy' THEN max_price ELSE NULL END) AS Premium_Economy
FROM max_price
GROUP BY quarter, flow_card
)
SELECT
	flow_card,
	quarter,
	economy AS first,
	first_class AS economy,
	business_class AS premium,
	premium_economy AS business
FROM union_data
	
