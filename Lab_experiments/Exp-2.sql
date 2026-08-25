-- =============================================================================
-- EXPERIMENT 2: ADVANCED SELECT, BETWEEN, IN, AND LIKE PREDICATES
-- =============================================================================

-- 1. Table Creation (DDL)
CREATE TABLE Job (
    job_id VARCHAR(15),
    job_title VARCHAR(30),
    min_sal DECIMAL(7,2),
    max_sal DECIMAL(7,2)
);

CREATE TABLE Employee (
    emp_no INT,
    emp_name VARCHAR(30),
    emp_sal DECIMAL(8,2),
    emp_comm DECIMAL(8,2),
    dept_no INT
);

CREATE TABLE exp2_deposit (
    a_no VARCHAR(5),
    cname VARCHAR(15),
    bname VARCHAR(10),
    amount DECIMAL(7,2),
    a_date DATE
);

CREATE TABLE exp2_borrow (
    loanno VARCHAR(5),
    cname VARCHAR(15),
    bname VARCHAR(10),
    amount DECIMAL(7,2)
);

-- 2. Data Insertion (DML)
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no) VALUES
(101, 'Smith', 800, NULL, 20),
(102, 'Snehal', 1600, 300, 25),
(103, 'Adama', 1100, 0, 20),
(104, 'Aman', 3000, NULL, 15),
(105, 'Anita', 5000, 50000, 10),
(106, 'Sneha', 2450, 24500, 10),
(107, 'Anamika', 2975, NULL, 30);

INSERT INTO Job (job_id, job_title, min_sal, max_sal) VALUES
('IT_PROG', 'Programmer', 4000, 10000),
('MK_MGR', 'Marketing manager', 9000, 15000),
('FI_MGR', 'Finance manager', 8200, 12000),
('FI_ACC', 'Account', 4200, 9000),
('LEC', 'Lecturer', 6000, 17000),
('COMP_OP', 'Computer Operator', 1500, 3000);

INSERT INTO exp2_deposit (a_no, cname, bname, amount, a_date) VALUES
('101', 'Anil', 'andheri', 7000, '2006-01-01'),
('102', 'Sunil', 'virar', 5000, '2006-07-15'),
('103', 'Jay', 'villeparle', 6500, '2006-03-12'),
('104', 'Vijay', 'andheri', 8000, '2006-09-17'),
('105', 'Keyur', 'dadar', 7500, '2006-11-19'),
('106', 'Mayor', 'borivali', 5500, '2006-12-21');

-- 3. Execution of Experiment 2 General Queries
-- Query 1: Data extraction
SELECT * FROM Employee;
SELECT * FROM Job;
SELECT * FROM exp2_deposit;

-- Query 2: Range evaluation using BETWEEN
SELECT a_no, amount FROM exp2_deposit WHERE a_date BETWEEN '2006-01-01' AND '2006-07-25';

-- Query 3: Comparison logic
SELECT * FROM Job WHERE min_sal > 4000;

-- Query 4: Schema attribute Alias matching
SELECT emp_name AS Employee_Name, emp_sal FROM Employee WHERE dept_no = 20;

-- Query 5: Grouped evaluation using IN
SELECT emp_no, emp_name, dept_no FROM Employee WHERE dept_no IN (10, 20);

-- 4. Advanced Pattern Matching (LIKE Predicate Queries)
-- Query 1: Character position checking (Start with 'A', 3rd char is 'a')
SELECT * FROM Employee WHERE emp_name LIKE 'A_a%';

-- Query 2: Exact character string length constraint (5 letters starting with 'Ani')
SELECT emp_name, emp_no, emp_sal FROM Employee WHERE emp_name LIKE 'Ani__';

-- Query 3: Multi-conditional filtering with non-null elements
SELECT * FROM Employee WHERE emp_comm IS NOT NULL AND emp_name LIKE '_n___';

-- Query 4: Null identification filter
SELECT * FROM Employee WHERE emp_comm IS NULL AND emp_name LIKE '__a%';

-- Query 5: Literal Wildcard escaping visualization
SELECT * FROM Employee WHERE emp_name LIKE '%\\_%' ESCAPE '\\';
