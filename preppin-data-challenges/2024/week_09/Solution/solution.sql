CREATE TABLE customer_actions(
	flight_number VARCHAR,
	flight_date VARCHAR,
	customer_id VARCHAR,
	action	TEXT,
	date	VARCHAR,
	class	TEXT,
	row	INT,
	seat	INT
);

ALTER TABLE customer_actions
ALTER COLUMN flight_date TYPE DATE USING flight_date::date;

ALTER TABLE customer_actions
ALTER COLUMN date TYPE DATE USING date::date;

SELECT * FROM customer_actions;

CREATE TABLE flight_details(
	flight_number VARCHAR,
	flight_date	VARCHAR,
	class	TEXT,
	capacity	INT
);

ALTER TABLE flight_details
ALTER COLUMN flight_date TYPE DATE USING flight_date::date;

SELECT * FROM flight_details;

-- Challenge Query

SELECT * 
FROM customer_actions 
WHERE (flight_number, customer_id) IN (
    SELECT flight_number, customer_id
    FROM customer_actions
    WHERE action = 'Cancelled'
);


DELETE FROM customer_actions
WHERE (flight_number, customer_id) IN (
    SELECT flight_number, customer_id
    FROM customer_actions
    WHERE action = 'Cancelled'
);


WITH ranked_actions AS(
	SELECT 
		*,
		RANK() OVER(PARTITION BY customer_id, flight_number ORDER BY date DESC) as rank
	FROM customer_actions
),
run_sum AS(
	SELECT 
		ra.flight_number,
		ra.flight_date,
		ra.class,
		COUNT(seat) OVER(PARTITION BY ra.flight_number,ra.class ORDER BY date) AS total_seats_booked_over_time,
		capacity,
		ra.customer_id,
		action,
		date,
		row,
		seat
	FROM ranked_actions AS ra
	JOIN flight_details AS fd
	ON 
		ra.flight_number = fd.flight_number
		AND
		ra.flight_date = fd.flight_date
		AND
		ra.class = fd.class
	WHERE rank = 1 
)
SELECT
	flight_number,
	flight_date,
	class,
	total_seats_booked_over_time,
	capacity,
	TRIM_SCALE(total_seats_booked_over_time :: numeric / capacity :: numeric) AS capacity_pct,
	customer_id,
	action,
	date,
	row,
	seat
FROM run_sum
