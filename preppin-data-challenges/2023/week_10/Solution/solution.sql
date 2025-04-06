CREATE TABLE account_statements(
	account_number INT,
	balance_date	VARCHAR,
	transaction_value	FLOAT,
	balance	FLOAT
);


-- Challenge Query

CREATE TABLE scaff_data(
	date	DATE
);

INSERT INTO scaff_data(date)
SELECT generate_series(
		'2023-01-31':: DATE,
		'2023-02-14':: DATE,
		INTERVAL '1 DAY'
	);

SELECT * FROM scaff_data;

set datestyle = 'dmy';

--

SELECT
	sd.date,
	account_number,
	COALESCE(SUM(transaction_value), 0) AS transaction_value,
	SUM(balance) AS balance
FROM scaff_data AS sd
LEFT JOIN account_statements AS ac
ON sd.date = ac.balance_date :: DATE
WHERE sd.date = '2023-02-01'
GROUP BY 1,2
ORDER BY 1
