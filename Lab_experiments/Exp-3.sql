-- =============================================================================
-- EXPERIMENT 3: DATA MANIPULATION, AGGREGATION, AND TABLE MANIPULATION
-- =============================================================================

-- 0. Use Table
use `250180107044`;

-- 1. List total deposit from deposit.
SELECT SUM(AMOUNT) AS Total_Deposit 
FROM DEPOSIT;

-- 2. List total loan from karolbagh branch
-- Using UPPER() to handle any potential lower/mixed case input values safely.
SELECT SUM(AMOUNT) AS Total_Loan_Karolbagh 
FROM BORROW 
WHERE UPPER(BNAME) = 'KAROLBAGH';

-- 3. Give maximum loan from branch vice.
-- "Branch vice" translates to branch-wise grouping (GROUP BY BNAME).
SELECT BNAME, MAX(AMOUNT) AS Max_Loan_BranchWise 
FROM BORROW 
GROUP BY BNAME;

-- 4. Count total number of customers
SELECT COUNT(*) AS Total_Customers_Exp1 
FROM CUSTOMERS;

-- 5. Count total number of customer’s cities.
-- DISTINCT prevents duplicate cities from artificially raising the count.
SELECT COUNT(DISTINCT CITY) AS Total_Unique_Cities_Exp1 
FROM CUSTOMERS;


-- -----------------------------------------------------------------------------
-- PART B: ALTERNATIVE QUERIES USING EXPERIMENT 2 TABLES (exp2_deposit, exp2_borrow)
-- -----------------------------------------------------------------------------

-- Alternative 1. List total deposit from exp2_deposit.
SELECT SUM(amount) AS Total_Deposit_Exp2 
FROM exp2_deposit;

-- Alternative 2. List total loan from karolbagh branch (or alternate branch)
-- Note: Practical 2 tables use 'andheri' and 'virar' branches. 
-- Both options are provided below. Choose the one your instructor wants to check.
SELECT SUM(amount) AS Total_Exp2_Loan_Karolbagh 
FROM exp2_borrow 
WHERE LOWER(bname) = 'karolbagh';

SELECT SUM(amount) AS Total_Exp2_Loan_Andheri_Alt 
FROM exp2_deposit 
WHERE LOWER(bname) = 'andheri';

-- Alternative 3. Give maximum loan from branch vice (Experiment 2 tables).
SELECT bname, MAX(amount) AS Max_Loan_BranchWise_Exp2 
FROM exp2_deposit 
GROUP BY bname;


-- -----------------------------------------------------------------------------
-- PART C: DATA RETRIEVAL & TABLE STRUCTURAL MANIPULATIONS (USING Employee TABLE)
-- -----------------------------------------------------------------------------

-- 6. Create table supplier from employee with all the columns.
CREATE TABLE supplier AS 
SELECT * FROM Employee;

-- 7. Create table sup1 from employee with first two columns.
-- Dynamically targets emp_no and emp_name structural profiles.
CREATE TABLE sup1 AS 
SELECT emp_no, emp_name 
FROM Employee;

-- 8. Create table sup2 from employee with no data
-- The 'WHERE 1 = 0' statement forces an empty structural clone.
CREATE TABLE sup2 AS 
SELECT * FROM Employee 
WHERE 1 = 0;

-- 9. Insert the data into sup2 from employee whose second character should be ‘n’ 
-- and string should be 5 characters long in employee name field.
-- MySQL pattern match logic: '_n___' strictly maps a length of exactly 5.
INSERT INTO sup2 
SELECT * FROM Employee 
WHERE emp_name LIKE '_n___';

-- 10. Delete all the rows from sup1.
DELETE FROM sup1;

-- 11. Delete the detail of supplier whose sup_no is 103.
-- Maps to the base 'emp_no' row definition cloned from Employee.
DELETE FROM supplier 
WHERE emp_no = 103;

-- 12. Rename the table sup2.
-- MySQL 8.0 compliant ALTER TABLE table-name RENAME TO target syntax.
ALTER TABLE sup2 RENAME TO sup2_renamed;

-- 13. Destroy table sup1 with all the data.
DROP TABLE IF EXISTS sup1;

-- 14. Update the value dept_no to 10 where second character of emp. name is ‘m’.
-- Uses trailing wildcard '%' to match strings of any length starting with anything, then 'm'.
UPDATE Employee 
SET dept_no = 10 
WHERE emp_name LIKE '_m%';

-- 15. Update the value of employee name whose employee number is 103.
UPDATE Employee 
SET emp_name = 'ADAM' 
WHERE emp_no = 103;
