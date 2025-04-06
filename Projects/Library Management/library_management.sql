-- Project Tasks
 
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
 
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members
SET	member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * 
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT(issued_id) AS total_issued_books
FROM issued_status
GROUP BY 1
HAVING count(issued_id)	> 1;	

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_counts AS
SELECT 
	book_title,
	isbn,
	COUNT(issued_id) AS total_book_issued_count
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_counts;


-- Data Analysis & Findings
-- Task 7: Retrieve All Books in a Specific Category:

SELECT *
FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category

SELECT 
	category,
	SUM(rental_price) AS total_rental_income
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days

SELECT * FROM members
WHERE reg_date >= CURRENT_TIMESTAMP - INTERVAL '180 Days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE books_price_greater_than_7
AS
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_7;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT *
FROM issued_status AS ist
LEFT JOIN returned_status AS rst
ON ist.issued_id = rst.return_book_isbn
WHERE rst.return_id IS NULL;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rst.return_date,
	CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status AS ist
JOIN members AS m
ON m.member_id = ist.issued_member_id
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN returned_status AS rst
ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_date IS NULL 
	AND
	(CURRENT_DATE - ist.issued_date)  > 30
ORDER BY 1;
	
-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

CREATE OR REPLACE PROCEDURE add_return_records(
	p_return_id VARCHAR, 
	p_issued_id VARCHAR
	)
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR;
    v_book_name VARCHAR;
    
BEGIN

    -- inserting into returns based on users input
    INSERT INTO returned_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$

-- Testing return records procedure
CALL add_return_records('RS138','IS135');

CALL add_return_records('RS148', 'IS140');

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_performance_report
AS
SELECT 
	b.branch_id,
	b.manager_id,
	SUM(bk.rental_price) AS total_revenue,
	COUNT(ist.issued_id) AS number_issued_books,
	COUNT(rst.return_id) AS number_returned_books
FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
LEFT JOIN returned_status AS rst
ON rst.issued_id = ist.issued_id
JOIN books AS bk
ON bk.isbn = ist.issued_book_isbn
GROUP BY 1,2;

SELECT * FROM branch_performance_report;

-- Task 16: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 10 months.

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '10 month'
	)
;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
	e.emp_name,
	b.*,
	COUNT(issued_id) AS number_processed_books
FROM employees AS e
JOIN issued_status AS ist
ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
GROUP BY 1,2;

-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.


CREATE OR REPLACE PROCEDURE issue_book(
	p_issued_id VARCHAR,
	P_issued_member_id VARCHAR,
	P_issued_book_isbn VARCHAR,
	p_issued_emp_id VARCHAR
	)

LANGUAGE plpgsql
AS $$

DECLARE
	-- Declaring variable
	v_status VARCHAR;


BEGIN
	-- logic for procedure
		-- checking if book is available ('yes')
		SELECT 
			status
		INTO
			v_status
		FROM books
		WHERE isbn = p_issued_book_isbn;

		IF v_status = 'yes' THEN
		
			INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			VALUES
			(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
			
			UPDATE books
			SET status = 'no'
			WHERE isbn = p_issued_book_isbn;
			
			RAISE NOTICE 'Book records added successfully for book ISBN: %', p_issued_book_isbn;
		
		ELSE
		
			RAISE NOTICE 'Sorry to inform you, but the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
			
		END IF;
		

END;
$$

-- Testing Procedure
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

SELECT 
	m.member_id,
	m.member_name,
	COUNT(ist.issued_id) AS number_overdue_books,
	SUM(CURRENT_DATE - ist.issued_date) :: integer * 0.50  AS total_fines
FROM issued_status AS ist
LEFT JOIN returned_status AS rst
ON ist.issued_id = rst.issued_id
JOIN members AS m
ON m.member_id = ist.issued_member_id
WHERE 
	rst.return_id IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) >= 30
GROUP BY 1,2;
