-- Library Management System Project 2

-- Creating Branch Table

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id	VARCHAR(10),
	branch_address	VARCHAR(60),
	contact_no	VARCHAR(10)
);

ALTER TABLE branch
ALTER COLUMN branch_id TYPE VARCHAR;

ALTER TABLE branch
ALTER COLUMN manager_id TYPE VARCHAR;

ALTER TABLE branch
ALTER COLUMN branch_address TYPE VARCHAR;

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR;

-- Creating Employees Table

DROP TABLE IF EXISTS employees;	
CREATE TABLE employees(
	emp_id VARCHAR PRIMARY KEY,
	emp_name	VARCHAR,
	position	VARCHAR,
	salary	INT,
	branch_id	VARCHAR --FK
);

ALTER TABLE employees
ALTER COLUMN salary TYPE FLOAT;

-- Creating Books Table

DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn	VARCHAR PRIMARY KEY,
	book_title	VARCHAR,
	category	VARCHAR,
	rental_price	FLOAT,
	status	VARCHAR,
	author	VARCHAR,
	publisher	VARCHAR
);

-- Creating Members Table

DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR PRIMARY KEY,
	member_name	VARCHAR,
	member_address	VARCHAR,
	reg_date	DATE
);


-- Creating Issued Status Table

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id	VARCHAR PRIMARY KEY,
	issued_member_id	VARCHAR, --FK
	issued_book_name	VARCHAR,
	issued_date	DATE,
	issued_book_isbn	VARCHAR, ---FK 
	issued_emp_id	VARCHAR --FK
);

-- Creating Return Status Table

DROP TABLE IF EXISTS returned_status;
CREATE TABLE returned_status(
	return_id	VARCHAR PRIMARY KEY,
	issued_id	VARCHAR, --FK
	return_book_name	VARCHAR,
	return_date	DATE,
	return_book_isbn	VARCHAR --FK
);

-- FOREIGN KEY

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id);

ALTER TABLE returned_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id);
