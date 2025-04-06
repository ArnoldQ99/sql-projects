CREATE TABLE flow_card(
	Customer_id	VARCHAR,
	seat	INT,
	Row	INT,
	Class	VARCHAR
);

SELECT * FROM flow_card;

CREATE TABLE non_flow_card(
	Customer_id	VARCHAR,
	seat	INT,
	Row	INT,
	Class	VARCHAR
);

CREATE TABLE non_flow_card2(
	Customer_id	VARCHAR,
	seat	INT,
	Row	INT,
	Class	VARCHAR
);

CREATE TABLE seat_plan(
	Class	VARCHAR,
	Seat	INT,
	Row	INT
);


-- Challenge Query

WITH union_data AS(
	SELECT *, 'Yes' AS flow_card FROM flow_card
	UNION ALL
	SELECT *, 'No' AS flow_card FROM non_flow_card
	UNION ALL
	SELECT *, 'No' AS flow_card FROM non_flow_card2
	),
cte AS(
	SELECT
		seat,
		row,
		class,
		flow_card,
		COUNT(customer_id) AS number_of_bookings
	FROM union_data
	GROUP BY 1,2,3,4
)
SELECT 
	sp.class,
	sp.seat,
	sp.row
FROM cte
FULL JOIN seat_plan AS sp
ON 
	cte.class = sp.class
	AND
	cte.seat = sp.seat
	AND
	cte.row = sp.row
WHERE number_of_bookings IS NULL
