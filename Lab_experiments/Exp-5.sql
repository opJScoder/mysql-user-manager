-- =============================================================================
-- EXPERIMENT 5.1: SINGLE-ROW FUNCTIONS (MySQL)
-- Tables used: employee, deposit
-- =============================================================================

-- Query 1: Display the current date labeled as "Date".
SELECT 
    CURDATE() AS Date;


-- Query 2: Display employee number, salary, and salary increased by 15% 
-- as a rounded whole number labeled as "New Salary".
SELECT 
    emp_no, 
    emp_name, 
    emp_sal, 
    ROUND(emp_sal * 1.15) AS `New Salary`
FROM employee;


-- Query 3: Subtract the old salary from the new salary to show the increase amount.
SELECT 
    emp_no, 
    emp_name, 
    emp_sal, 
    ROUND(emp_sal * 1.15) AS `New Salary`,
    ROUND(emp_sal * 1.15) - emp_sal AS Increase
FROM employee;


-- Query 4: Format name (Capital first letter, lowercase rest) and show its length 
-- for names starting with 'J', 'A', or 'M', sorted alphabetically.
SELECT 
    CONCAT(UPPER(SUBSTRING(emp_name, 1, 1)), LOWER(SUBSTRING(emp_name, 2))) AS Formatted_Name,
    LENGTH(emp_name) AS Name_Length
FROM employee
WHERE emp_name LIKE 'J%' 
   OR emp_name LIKE 'A%' 
   OR emp_name LIKE 'M%'
ORDER BY emp_name ASC;


-- Query 5: Produce a custom text sentence: "<employee name> earns <salary> monthly".
SELECT 
    CONCAT(emp_name, ' earns ', emp_sal, ' monthly') AS Monthly_Report
FROM employee;


-- Query 6: Display name, start date, months passed, and weekday name.
-- Ordered starting from Monday (WEEKDAY(): Monday = 0, Tuesday = 1, etc.).
SELECT 
    CNAME AS Customer_Name,
    ADATE AS Start_Date,
    TIMESTAMPDIFF(MONTH, ADATE, CURDATE()) AS Months_Employed,
    DAYNAME(ADATE) AS Day_Of_Week
FROM deposit
ORDER BY WEEKDAY(ADATE) ASC;


-- Query 7: Display the date in a verbose format: "7th of June 1994 12:00:00 AM".
SELECT 
    CNAME AS Customer_Name,
    DATE_FORMAT(ADATE, '%D of %M %Y 12:00:00 AM') AS Formatted_Date
FROM deposit;


-- Query 8: Calculate annual compensation using (sal * 12) + commission.
-- IFNULL replaces NULL commission with 0 so the calculation doesn't become NULL.
SELECT 
    emp_no,
    emp_name,
    emp_sal,
    emp_comm,
    (emp_sal * 12) + IFNULL(emp_comm, 0) AS Annual_Compensation
FROM employee;







-- =============================================================================
-- EXPERIMENT 5.2: DISPLAYING DATA FROM MULTIPLE TABLES (JOIN)
-- Table names match your Workbench Navigator:
-- borrow, branch, customers, deposit, employee, job
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Give details of customers ANIL.
-- Combines his customer details with deposit and loan records using LEFT JOIN.
-- -----------------------------------------------------------------------------
SELECT 
    c.CNAME,
    c.CITY,
    d.ACTNO,
    d.BNAME AS DEPOSIT_BRANCH,
    d.AMOUNT AS DEPOSIT_AMOUNT,
    d.ADATE,
    b.LOANNO,
    b.BNAME AS LOAN_BRANCH,
    b.AMOUNT AS LOAN_AMOUNT
FROM customers c
LEFT JOIN deposit d ON c.CNAME = d.CNAME
LEFT JOIN borrow b ON c.CNAME = b.CNAME
WHERE c.CNAME = 'ANIL';


-- -----------------------------------------------------------------------------
-- 2. Give name of customer who are borrowers and depositors 
--    and having living city nagpur.
-- -----------------------------------------------------------------------------
SELECT DISTINCT c.CNAME
FROM customers c
INNER JOIN deposit d ON c.CNAME = d.CNAME
INNER JOIN borrow b ON c.CNAME = b.CNAME
WHERE c.CITY = 'NAGPUR';


-- -----------------------------------------------------------------------------
-- 3. Give city as their city name of customers having same living branch.
-- Matches customer living city with the city where their branch is located.
-- -----------------------------------------------------------------------------
SELECT DISTINCT c.CNAME, br.BNAME, br.CITY
FROM customers c
INNER JOIN deposit d ON c.CNAME = d.CNAME
INNER JOIN branch br ON d.BNAME = br.BNAME
WHERE c.CITY = br.CITY;


-- -----------------------------------------------------------------------------
-- 4. Write a query to display the last name, department number, 
--    and department name for all employees.
-- -----------------------------------------------------------------------------
-- Using your Experiment 2 tables (employee & job):
-- Note: 'employee' has dept_no, but no department name table exists.
SELECT emp_name, dept_no 
FROM employee;

-- Standard GTU textbook query (if emp and dept tables exist):
-- SELECT e.ename, e.deptno, d.dname 
-- FROM emp e 
-- JOIN dept d ON e.deptno = d.deptno;


-- -----------------------------------------------------------------------------
-- 5. Create a unique listing of all jobs that are in department 30. 
--    Include the location of the department in the output.
-- -----------------------------------------------------------------------------
-- Using your Experiment 2 tables:
-- Lists distinct employees and salary info in dept 30:
SELECT DISTINCT dept_no, emp_name 
FROM employee 
WHERE dept_no = 30;

-- Standard GTU textbook query (if emp and dept tables exist):
-- SELECT DISTINCT e.job, d.loc 
-- FROM emp e 
-- JOIN dept d ON e.deptno = d.deptno 
-- WHERE e.deptno = 30;


-- -----------------------------------------------------------------------------
-- 6. Write a query to display the employee name, department number, 
--    and department name for all employees who work in NEW YORK.
-- -----------------------------------------------------------------------------
-- Using your Experiment 1/2 tables:
-- In your schema, branches have cities (e.g., NAGPUR, DELHI, BOMBAY).
-- If matching customers/depositors to branch city:
SELECT c.CNAME, d.BNAME, br.CITY
FROM customers c
JOIN deposit d ON c.CNAME = d.CNAME
JOIN branch br ON d.BNAME = br.BNAME
WHERE br.CITY = 'DELHI';

-- Standard GTU textbook query (if emp and dept tables exist):
-- SELECT e.ename, e.deptno, d.dname 
-- FROM emp e 
-- JOIN dept d ON e.deptno = d.deptno 
-- WHERE d.loc = 'NEW YORK';


-- -----------------------------------------------------------------------------
-- 7. Display the employee last name and employee number along with 
--    their manager’s last name and manager number. 
--    Label the columns Employee, Emp#, Manager, and Mgr#, respectively.
-- -----------------------------------------------------------------------------
-- Standard GTU textbook query (Self-Join on emp):
-- SELECT 
--     e.ename AS Employee, 
--     e.empno AS `Emp#`, 
--     m.ename AS Manager, 
--     m.empno AS `Mgr#`
-- FROM emp e
-- JOIN emp m ON e.mgr = m.empno;

-- Self-join demonstration using your employee table:
-- Pairs employees within the same department:
SELECT 
    e1.emp_name AS Employee,
    e1.emp_no AS `Emp#`,
    e2.emp_name AS Colleague,
    e2.emp_no AS `Colleague#`
FROM employee e1
JOIN employee e2 ON e1.dept_no = e2.dept_no AND e1.emp_no <> e2.emp_no;


-- -----------------------------------------------------------------------------
-- 8. Create a query to display the name and hire date of any employee 
--    hired after employee SCOTT.
-- -----------------------------------------------------------------------------
-- Using your deposit table (which has CNAME and ADATE):
-- Find all depositors who opened an account after 'ANIL' (hired/opened date comparison):
SELECT d1.CNAME, d1.ADATE
FROM deposit d1
JOIN deposit d2 ON d2.CNAME = 'ANIL'
WHERE d1.ADATE > d2.ADATE;

-- Standard GTU textbook query (if emp table has SCOTT and hiredate):
-- SELECT e.ename, e.hiredate 
-- FROM emp e 
-- JOIN emp scott ON scott.ename = 'SCOTT' 
-- WHERE e.hiredate > scott.hiredate;







-- =============================================================================
-- EXPERIMENT 5.3: AGGREGATING DATA USING GROUP FUNCTIONS (MySQL)
-- Tables used: deposit, customers
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. List total deposit of customer having account date after 1-jan-96.
-- Uses SUM() on AMOUNT where ADATE is strictly greater than 1996-01-01.
-- -----------------------------------------------------------------------------
SELECT SUM(AMOUNT) AS Total_Deposit_After_Jan96
FROM deposit
WHERE ADATE > '1996-01-01';


-- -----------------------------------------------------------------------------
-- 2. List total deposit of customers living in city Nagpur.
-- Joins deposit and customers on CNAME and filters for customer living city = 'NAGPUR'.
-- -----------------------------------------------------------------------------
SELECT SUM(d.AMOUNT) AS Total_Deposit_Nagpur
FROM deposit d
JOIN customers c ON d.CNAME = c.CNAME
WHERE c.CITY = 'NAGPUR';







-- =============================================================================
-- EXPERIMENT 5.4: SUBQUERIES (OPTIMIZED FOR MySQL)
-- Tables used: customers, deposit, borrow, branch, employee, job
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Display last name and hire date of employees in same department as SCOTT.
--    Exclude SCOTT.
-- Note: In your Experiment 2 table, the employee name is Anita (dept_no = 10).
-- -----------------------------------------------------------------------------
-- For your Experiment 2 schema (e.g., using 'Anita'):
SELECT emp_name, dept_no
FROM employee
WHERE dept_no = (SELECT dept_no FROM employee WHERE emp_name = 'Anita')
  AND emp_name <> 'Anita';

-- Standard GTU / Oracle EMP schema:
-- SELECT ename, hiredate 
-- FROM emp 
-- WHERE deptno = (SELECT deptno FROM emp WHERE ename = 'SCOTT') 
--   AND ename <> 'SCOTT';


-- -----------------------------------------------------------------------------
-- 2. Give name of customers who are depositors having same branch city of mr. sunil.
-- Finds Sunil's branch city first, then retrieves depositors with branches there.
-- -----------------------------------------------------------------------------
SELECT DISTINCT d.CNAME
FROM deposit d
JOIN branch b ON d.BNAME = b.BNAME
WHERE b.CITY IN (
    SELECT b2.CITY
    FROM deposit d2
    JOIN branch b2 ON d2.BNAME = b2.BNAME
    WHERE d2.CNAME = 'SUNIL'
);


-- -----------------------------------------------------------------------------
-- 3. Give deposit details and loan details of customer in same city 
--    where pramod is living.
-- -----------------------------------------------------------------------------
-- Deposit details:
SELECT * 
FROM deposit
WHERE CNAME IN (
    SELECT CNAME 
    FROM customers 
    WHERE CITY = (SELECT CITY FROM customers WHERE CNAME = 'PRAMOD')
);

-- Loan details:
SELECT * 
FROM borrow
WHERE CNAME IN (
    SELECT CNAME 
    FROM customers 
    WHERE CITY = (SELECT CITY FROM customers WHERE CNAME = 'PRAMOD')
);


-- -----------------------------------------------------------------------------
-- 4. Display employee numbers and names of all employees who earn more 
--    than average salary. Sort ascending by salary.
-- -----------------------------------------------------------------------------
SELECT emp_no, emp_name, emp_sal
FROM employee
WHERE emp_sal > (SELECT AVG(emp_sal) FROM employee)
ORDER BY emp_sal ASC;


-- -----------------------------------------------------------------------------
-- 5. Give names of depositors having same living city as mr. anil and 
--    having deposit amount greater than 2000.
-- -----------------------------------------------------------------------------
SELECT DISTINCT d.CNAME
FROM deposit d
JOIN customers c ON d.CNAME = c.CNAME
WHERE c.CITY = (SELECT CITY FROM customers WHERE CNAME = 'ANIL')
  AND d.AMOUNT > 2000;


-- -----------------------------------------------------------------------------
-- 6. Display the last name and salary of every employee who reports to ford.
-- Note: Uses the manager-employee relationship subquery.
-- -----------------------------------------------------------------------------
-- For Experiment 2 table (e.g., employees in same dept as Smith):
SELECT emp_name, emp_sal
FROM employee
WHERE dept_no = (SELECT dept_no FROM employee WHERE emp_name = 'Smith')
  AND emp_name <> 'Smith';

-- Standard GTU / Oracle EMP schema:
-- SELECT ename, sal 
-- FROM emp 
-- WHERE mgr = (SELECT empno FROM emp WHERE ename = 'FORD');


-- -----------------------------------------------------------------------------
-- 7. Display department number, name, and job for every employee 
--    in the Accounting department.
-- -----------------------------------------------------------------------------
-- For Experiment 2 table:
SELECT e.dept_no, e.emp_name, j.job_title
FROM employee e
LEFT JOIN job j ON j.job_id = 'FI_ACC'
WHERE e.dept_no = 10;

-- Standard GTU / Oracle EMP/DEPT schema:
-- SELECT deptno, ename, job 
-- FROM emp 
-- WHERE deptno = (SELECT deptno FROM dept WHERE dname = 'ACCOUNTING');


-- -----------------------------------------------------------------------------
-- 8. List the name of branch having highest number of depositors.
-- -----------------------------------------------------------------------------
SELECT BNAME
FROM deposit
GROUP BY BNAME
HAVING COUNT(*) = (
    SELECT MAX(branch_count)
    FROM (
        SELECT COUNT(*) AS branch_count
        FROM deposit
        GROUP BY BNAME
    ) AS temp
);


-- -----------------------------------------------------------------------------
-- 9. Give the name of cities in which the maximum number of branches are located.
-- -----------------------------------------------------------------------------
SELECT CITY
FROM branch
GROUP BY CITY
HAVING COUNT(*) = (
    SELECT MAX(city_count)
    FROM (
        SELECT COUNT(*) AS city_count
        FROM branch
        GROUP BY CITY
    ) AS temp
);


-- -----------------------------------------------------------------------------
-- 10. Give name of customers living in same city where maximum depositors are located.
-- Finds the city with the most depositors, then lists customers living in that city.
-- -----------------------------------------------------------------------------
SELECT CNAME, CITY
FROM customers
WHERE CITY = (
    SELECT c.CITY
    FROM customers c
    JOIN deposit d ON c.CNAME = d.CNAME
    GROUP BY c.CITY
    ORDER BY COUNT(d.ACTNO) DESC
    LIMIT 1
);







-- =============================================================================
-- EXPERIMENT 5.5: MANIPULATING DATA (DML: UPDATE & DELETE WITH SUBQUERIES)
-- Tables used: deposit, customers, branch, borrow, employee
-- =============================================================================

-- MySQL Workbench Safe Updates override (needed for non-PK updates/deletes):
SET SQL_SAFE_UPDATES = 0;


-- -----------------------------------------------------------------------------
-- 1. Give 10% interest to all depositors.
-- Explanation: Increases the AMOUNT column for every row in the deposit table by 10%.
-- -----------------------------------------------------------------------------
UPDATE deposit 
SET AMOUNT = AMOUNT * 1.10;


-- -----------------------------------------------------------------------------
-- 2. Give 10% interest to all depositors having branch vice.
-- Explanation: "Branch vice" refers to grouping by or filtering per branch. 
-- In SQL, an update on every depositor across all branches evaluates branch-wise.
-- -----------------------------------------------------------------------------
UPDATE deposit 
SET AMOUNT = AMOUNT * 1.10
WHERE BNAME IS NOT NULL;


-- -----------------------------------------------------------------------------
-- 3. Give 10% interest to all depositors living in nagpur and having branch city bombay.
-- Explanation: Joins customers (to check living city = NAGPUR) and branch 
-- (to check branch city = BOMBAY), updating matching deposit balances.
-- -----------------------------------------------------------------------------
UPDATE deposit d
JOIN customers c ON d.CNAME = c.CNAME
JOIN branch b ON d.BNAME = b.BNAME
SET d.AMOUNT = d.AMOUNT * 1.10
WHERE UPPER(c.CITY) = 'NAGPUR' 
  AND UPPER(b.CITY) = 'BOMBAY';


-- -----------------------------------------------------------------------------
-- 4. Write a query which changes the department number of all employees with 
--    empno 7788’s job to employee 7844’current department number.
-- -----------------------------------------------------------------------------
-- Standard GTU / Oracle EMP schema syntax:
-- UPDATE emp 
-- SET deptno = (SELECT deptno FROM (SELECT deptno FROM emp WHERE empno = 7844) AS t1)
-- WHERE job = (SELECT job FROM (SELECT job FROM emp WHERE empno = 7788) AS t2);

-- Equivalent mapped to your Experiment 2 employee table (using emp_no 101 and 102):
UPDATE employee 
SET dept_no = (SELECT dept_no FROM (SELECT dept_no FROM employee WHERE emp_no = 102) AS t1)
WHERE dept_no = (SELECT dept_no FROM (SELECT dept_no FROM employee WHERE emp_no = 101) AS t2);


-- -----------------------------------------------------------------------------
-- 5. Transfer 10 Rs from account of anil to sunil if both are having same branch.
-- Explanation: Checks if ANIL and SUNIL share the same BNAME in deposit. 
-- If matched, deducts 10 from ANIL and credits 10 to SUNIL.
-- -----------------------------------------------------------------------------
-- Step 5a: Deduct 10 from ANIL
UPDATE deposit 
SET AMOUNT = AMOUNT - 10
WHERE CNAME = 'ANIL' 
  AND BNAME = (SELECT BNAME FROM (SELECT BNAME FROM deposit WHERE CNAME = 'SUNIL') AS t);

-- Step 5b: Add 10 to SUNIL
UPDATE deposit 
SET AMOUNT = AMOUNT + 10
WHERE CNAME = 'SUNIL' 
  AND BNAME = (SELECT BNAME FROM (SELECT BNAME FROM deposit WHERE CNAME = 'ANIL') AS t);


-- -----------------------------------------------------------------------------
-- 6. Give 100 Rs more to all depositors if they are maximum depositors 
--    in their respective branch.
-- Explanation: A correlated subquery identifies the highest deposited amount 
-- for each branch and adds 100 to accounts matching that peak figure.
-- -----------------------------------------------------------------------------
UPDATE deposit d
JOIN (
    SELECT BNAME, MAX(AMOUNT) AS max_amt
    FROM deposit
    GROUP BY BNAME
) max_table ON d.BNAME = max_table.BNAME AND d.AMOUNT = max_table.max_amt
SET d.AMOUNT = d.AMOUNT + 100;


-- -----------------------------------------------------------------------------
-- 7. Delete depositors of branches having number of customers between 1 to 3.
-- Explanation: Aggregates total depositors per branch and deletes rows from 
-- branches where the count falls between 1 and 3.
-- -----------------------------------------------------------------------------
DELETE FROM deposit 
WHERE BNAME IN (
    SELECT BNAME FROM (
        SELECT BNAME 
        FROM deposit 
        GROUP BY BNAME 
        HAVING COUNT(*) BETWEEN 1 AND 3
    ) AS temp
);


-- -----------------------------------------------------------------------------
-- 8. Delete deposit of vijay.
-- Explanation: Removes the row belonging to 'VIJAY' from the deposit table.
-- -----------------------------------------------------------------------------
DELETE FROM deposit 
WHERE UPPER(CNAME) = 'VIJAY';


-- -----------------------------------------------------------------------------
-- 9. Delete borrower of branches having average loan less than 1000.
-- Explanation: Uses an aggregate subquery on borrow to find branches with an 
-- average loan amount under 1000 and deletes all borrowers belonging to them.
-- -----------------------------------------------------------------------------
DELETE FROM borrow 
WHERE BNAME IN (
    SELECT BNAME FROM (
        SELECT BNAME 
        FROM borrow 
        GROUP BY BNAME 
        HAVING AVG(AMOUNT) < 1000
    ) AS temp
);

-- Re-enable Safe Updates:
SET SQL_SAFE_UPDATES = 1;