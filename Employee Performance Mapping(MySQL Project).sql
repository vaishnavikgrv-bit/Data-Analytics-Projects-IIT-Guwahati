
-- ScienceQtech Employee Performance Mapping.
-- Course-end Project 1 By Vaishnavi Singh

-- 1.Create a database named employee, then import data_science_team.csv,
-- proj_table.csv and emp_record_table.csv into the employee database from the given resources.

CREATE DATABASE if not exists employee;
Use employee;

CREATE TABLE if not exists emp_record_table
(
EMP_ID VARCHAR(20) NOT NULL PRIMARY KEY,
FIRST_NAME VARCHAR (100) NOT NULL,
LAST_NAME VARCHAR (100)NOT NULL,
GENDER VARCHAR (10) NOT NULL,
ROLE VARCHAR(100) NOT NULL,
DEPT VARCHAR(100)NOT NULL,
EXP INT NOT NULL CHECK (Exp>=0),
COUNTRY VARCHAR(80) NOT NULL,
CONTINENT VARCHAR(50)NOT NULL,
SALARY INT NOT NULL CHECK(Salary>=0),
EMP_RATING INT NOT NULL CHECK(Emp_Rating>=0),
MANAGER_ID VARCHAR (100)  NULL,
PROJ_ID VARCHAR (100)NULL,
CONSTRAINT EMPID_CHECK CHECK(substring(EMP_ID,1,1)= 'E'),
CONSTRAINT MANID_CHECK CHECK(substring(MANAGER_ID,1,1)= 'E'),
CONSTRAINT GENDER_CHECK CHECK(GENDER IN('M','F','O'))
) engine = InnoDB;



create table if not exists Proj_table (
PROJECT_ID VARCHAR(4) NOT NULL PRIMARY KEY,
PROJ_NAME VARCHAR(200) NOT NULL,
DOMAIN VARCHAR(100) NOT NULL,
START_DATE TEXT NOT NULL,
CLOSURE_DATE TEXT NOT NULL,
DEV_QTR VARCHAR(2) NOT NULL,
STATUS VARCHAR(7) NOT NULL,
CONSTRAINT PROJID_CHECK CHECK(substring(PROJECT_ID,1,1)='P'),
CONSTRAINT CHECK_STATUS CHECK(STATUS IN ('YTS','WIP','DONE','DELAYED'))
) engine=InnoDB;


CREATE TABLE IF NOT EXISTS Data_science_team (
EMP_ID VARCHAR(20) NOT NULL PRIMARY KEY,
FIRST_NAME VARCHAR(100) NOT NULL,
LAST_NAME VARCHAR(100) NOT NULL,
GENDER VARCHAR (10) NOT NULL,
ROLE VARCHAR(100) NOT NULL,
DEPT VARCHAR (100)NOT NULL,
EXP INT NOT NULL CHECK(Exp>=0),
COUNTRY VARCHAR(80) NOT NULL,
CONTINENT VARCHAR(80)NOT NULL,
CONSTRAINT dsid_check CHECK(substring(EMP_ID,1,1)='E'),
CONSTRAINT dsgender_check CHECK(Gender in ('M','F','O'))
)engine= InnoDB;

SELECT * FROM employee.data_science_team;

SELECT * FROM emp_record_table;

SELECT * FROM proj_table;


-- 3. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and
-- DEPARTMENT from the employee record table, and make a list of employees
-- and details of their department.

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table
ORDER BY DEPT;


-- 4. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER,
-- DEPARTMENT, and EMP_RATING if the EMP_RATING is:
-- ● less than two
-- ● greater than four
-- ● between two and four

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING > 4;


SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4;


-- 5.Write a query to concatenate the FIRST_NAME and the LAST_NAME of
-- employees in the Finance department from the employee table and then give
-- the resultant column alias as NAME.

SELECT CONCAT(FIRST_NAME," ",LAST_NAME)AS NAME
FROM emp_record_table
WHERE DEPT = "FINANCE";


-- 6. Write a SQL query to retrieve the employee ID, first name, role, and
-- department of employees who hold leadership positions (Manager,
-- President, or CEO).

SELECT EMP_ID, FIRST_NAME, ROLE, DEPT 
FROM emp_record_table
WHERE ROLE IN ("Manager","President","CEO");


-- 7. Write a query to list all the employees from the healthcare and finance
-- departments using the union. Take data from the employee record table.

SELECT e1.EMP_ID, e1.FIRST_NAME, e1.LAST_NAME, e1.DEPT
FROM emp_record_table e1
WHERE e1.DEPT IN ("Healthcare","Finance")
UNION
SELECT e1.EMP_ID, e1.FIRST_NAME, e1.LAST_NAME, e1.DEPT
FROM emp_record_table e1
WHERE e1.DEPT IN ("Healthcare","Finance")
ORDER BY DEPT;



-- 8.Write a query to list employee details such as EMP_ID, FIRST_NAME,
-- LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. Also
-- include the respective employee rating along with the max emp rating for the
-- department.

SELECT
      EMP_ID,
      FIRST_NAME, 
      LAST_NAME,
      ROLE,
      DEPT,
      EMP_RATING ,
      MAX(EMP_RATING) OVER(PARTITION BY DEPT) AS Max_Emp_Rating
    FROM emp_record_table;



-- 9. Write a query to calculate the minimum and the maximum salary of the
-- employees in each role. Take data from the employee record table.

SELECT ROLE,MIN(SALARY)AS MIN_SALARY,MAX(SALARY)AS MAX_SALARY
FROM emp_record_table
GROUP BY ROLE;




-- 10.Write a query to assign ranks to each employee based on their experience.
-- Take data from the employee record table.


SELECT EMP_ID,
       FIRST_NAME,
       LAST_NAME,
       ROLE,
       DEPT,
       EXP,
       DENSE_RANK()OVER (ORDER BY EXP DESC)AS EMP_EXPERIENCE_RANK
FROM emp_record_table;




-- 11. Write a query to create a view that displays employees in various countries whose salary is more than six
-- thousand. Take data from the employee record table.

CREATE VIEW Employee_Salary_View AS
SELECT EMP_ID, COUNTRY,SALARY
FROM emp_record_table
WHERE SALARY > 6000;

SELECT * FROM employee.employee_salary_view;


-- 12.Write a nested query to find employees with experience of more than ten
-- years. Take data from the employee record table. 

SELECT EMP_ID,FIRST_NAME,LAST_NAME,DEPT,EXP
FROM emp_record_table
WHERE EXP IN (SELECT EXP FROM emp_record_table WHERE EXP> 10 );



-- 13.Write a query using stored functions in the project table to check whether
-- the job profile assigned to each employee in the data science team matches
-- the organization’s set standard.
-- The standard being:
-- For an employee with experience less than or equal to 2 years assign 'JUNIOR
-- DATA SCIENTIST',
-- For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA
-- SCIENTIST',
-- For an employee with the experience of 5 to 10 years assign 'SENIOR DATA
-- SCIENTIST',
-- For an employee with the experience of 10 to 12 years assign 'LEAD DATA
-- SCIENTIST',
-- For an employee with the experience of 12 to 16 years assign 'MANAGER'.


DELIMITER //
 -- DROP FUNCTION IF EXISTS GetStandardJobProfile;

CREATE FUNCTION GetStandardJobProfile(EXP INT(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
     DECLARE STD_JOB_PROFILE VARCHAR(100);

 IF EXP <=2 THEN
   SET  STD_JOB_PROFILE = 'JUNIOR DATA SCIENTIST';
 ELSEIF EXP <= 5 THEN
   SET STD_JOB_PROFILE  ='ASSOCIATE DATA SCIENTIST';
 ELSEIF EXP <=10 THEN
   SET STD_JOB_PROFILE  = 'SENIOR DATA SCIENTIST';
 ELSEIF EXP <=12 THEN
   SET STD_JOB_PROFILE  ='LEAD DATA SCIENTIST';
 ELSEIF EXP <=16 THEN  
   SET STD_JOB_PROFILE  = 'MANAGER';
 END IF;
 
 RETURN STD_JOB_PROFILE ;
END //

DELIMITER ;
 
SELECT 
   EMP_ID,
   FIRST_NAME,
   LAST_NAME,
   ROLE,
   EXP, 
   GetStandardJobProfile(EXP)AS STANDARD_ROLE,
CASE
   WHEN ROLE = GetStandardJobProfile(EXP) THEN "Job Profile Matches Standard"
   ELSE "Job Profile Does Not Match Standard"
END AS JOB_PROFILE_MATCH_STATUS

FROM
    data_science_team
ORDER BY EXP ASC;


-- 14.Create an index to improve the cost and performance of the query to find
-- the employee whose FIRST_NAME is ‘Eric’ in the employee table after
-- checking the execution plan.

   CREATE INDEX idx_firstname ON emp_record_table(FIRST_NAME(100));
   
   SELECT * from emp_record_table WHERE FIRST_NAME ='Eric';
   Explain  SELECT * from emp_record_table WHERE FIRST_NAME ='Eric';
   



-- 15.Write a query to calculate the bonus for all the employees, based on their
-- ratings and salaries (Use the formula: 5% of salary * employee rating).


SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER,ROLE, SALARY, EMP_RATING, ROUND(0.05 * SALARY * EMP_RATING) AS BONUS  
FROM emp_record_table
ORDER BY BONUS DESC;


-- 16.Write a query to calculate the average salary distribution based on the
-- continent and country. Take data from the employee record table.


SELECT
    CONTINENT,
    COUNTRY,
	AVG(SALARY)AS AVERAGE_SALARY
FROM 
    emp_record_table
GROUP BY CONTINENT, COUNTRY WITH ROLLUP;


	
    
    



