CREATE TABLE prep_air_2024_flights(
	date	DATE,
	flight_number	VARCHAR,
	flight_from	TEXT,
	flight_to	TEXT
);

SELECT * FROM prep_air_2024_flights;

CREATE TABLE prep_air_customers(
	customer_id	INT,
	last_date_flown	DATE,
	first_name	TEXT,
	last_name	TEXT,
	email	VARCHAR,
	gender	TEXT
);

SELECT * FROM prep_air_customers;

CREATE TABLE prep_air_ticket_sales(
	date	DATE,
	flight_number	VARCHAR,
	customer_id	INT,
	ticket_price	FLOAT
);

SELECT * FROM prep_air_ticket_sales


-- 1st Output

SELECT 
	ts.date,
	f.flight_from,
	f.flight_to,
	f.flight_number,
	ts.customer_id,
	c.last_date_flown,
	c.first_name,
	c.last_name,
	c.email,
	c.gender,
	ts.ticket_price
FROM prep_air_ticket_sales AS ts
JOIN prep_air_2024_flights AS f
ON 
	f.date = ts.date
	AND
	f.flight_number = ts.flight_number
JOIN prep_air_customers AS c
ON c.customer_id = ts.customer_id


-- 2nd Output

SELECT 
	'31/01/2024' AS flights_unbooked_as_of,
	f.date,
	f.flight_number,
	f.flight_from,
	f.flight_to
FROM prep_air_2024_flights AS f
FULL JOIN prep_air_ticket_sales AS ts
ON 
	f.date = ts.date
	AND
	f.flight_number = ts.flight_number
WHERE customer_id iS NULL

-- 3rd Output

SET datestyle = dmy;

SELECT
	c.customer_id,
	('31/01/2024' :: DATE) - c.last_date_flown AS days_since_last_flown,
	CASE
		WHEN (('31/01/2024' :: DATE) - c.last_date_flown) < 90 THEN 'Recent fliers - flown within the last 3 months'
		WHEN (('31/01/2024' :: DATE) - c.last_date_flown) BETWEEN 90 AND 180 THEN 'Taking a break - 3-6 months since last flight'
		WHEN (('31/01/2024' :: DATE) - c.last_date_flown) BETWEEN 180 AND 270 THEN 'Been away a while - 6-9 months since last flight'
		ELSE 'Lapsed Customers - over 9 months since last flight'
	END AS customer_category,
	c.last_date_flown,
	c.first_name,
	c.last_name,
	c.email,
	c.gender
FROM prep_air_2024_flights AS f
JOIN prep_air_ticket_sales AS ts
ON 
	ts.date = f.date
	AND
	ts.flight_number = f.flight_number
RIGHT JOIN prep_air_customers AS c
ON c.customer_id = ts.customer_id
WHERE ts.customer_id IS NULL
