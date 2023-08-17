select * from HR

use HR;

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Write a SQL query to find the average, minimum, and maximum total working years for employees who have 'High' environment satisfaction 
--    but have not received any promotions ('Years Since Last Promotion' is 0) in their current role.

SELECT
    CASE WHEN "EnvironmentSatisfaction" = 4 THEN 'High' ELSE 'Not High' END AS EnvironmentSatisfaction,
    AVG("TotalWorkingYears") AS Average_Working_Years,
    MIN("TotalWorkingYears") AS Minimum_Working_Years,
    MAX("TotalWorkingYears") AS Maximum_Working_Years
FROM
    HR
WHERE
    EnvironmentSatisfaction = 4
    AND "YearsSinceLastPromotion" = 0
GROUP BY
    EnvironmentSatisfaction;

-- This query calculates the average, minimum, and maximum total working years for employees with 'High' environment satisfaction 
-- (corresponding to a value of 4) who have not received any promotions. The CASE statement creates a separate column called "EnvironmentSatisfaction" 
-- to indicate whether the satisfaction is 'High' or 'Not High'. The results are grouped by the "EnvironmentSatisfaction" column.

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Identify any patterns in performance ratings for employees who have 'Over Time' enabled and 'Job Involvement' level greater than 3.

SELECT
    "PerformanceRating",
    "JobInvolvement",
    "OverTime",
    COUNT(*) AS "Number_of_Employees"
FROM
    HR
WHERE
    "OverTime" = 'Yes'
    AND "JobInvolvement" > 3
GROUP BY
    "PerformanceRating",
    "JobInvolvement",
    "OverTime";

-- This query will display the performance rating, job involvement level, overtime status, and the number of employees 
-- who meet the specified conditions (having 'Over Time' enabled and 'Job Involvement' level greater than 3). 
-- The results will be grouped based on these columns.

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Calculate the attrition rate of employees in the company. The attrition rate is defined as the percentage of employees who have left 
--    the company (Attrition = 'Yes') compared to the total number of employees. Round the attrition rate to two decimal places.

SELECT
    ROUND((COUNT(CASE WHEN "Attrition" = 'Yes' THEN 1 END) * 100.0 / COUNT(*)), 2) AS Attrition_Rate
FROM
    hr;

-- This query counts the number of employees with 'Attrition' set to 'Yes' (i.e., those who have left the company), 
-- divides it by the total number of employees, and then multiplies by 100 to get the attrition rate. 
-- The ROUND function is used to round the result to two decimal places.

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. Determine the probability of an employee receiving a promotion. The promotion probability is defined as the percentage of employees 
--    who have received at least one promotion ('Years Since Last Promotion' > 0) compared to the total number of employees. 
--    Round the probability to two decimal places.

SELECT
    ROUND((COUNT(CASE WHEN "YearsSinceLastPromotion" > 0 THEN 1 END) * 100.0 / COUNT(*)), 2) AS Promotion_Probability
FROM
    hr;

-- This query counts the number of employees with 'Years Since Last Promotion' greater than 0 (i.e., those who have received at least one promotion), 
-- divides it by the total number of employees, and then multiplies by 100 to get the promotion probability. 
-- The ROUND function is used to round the result to two decimal places.

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. Find the top 5 employees who received the maximum salary hike ('Percent Salary Hike') during their last performance review. 
--    Display the employee name and the corresponding salary hike in descending order.

SELECT TOP 5
    CONCAT("empno", ': ', "EmployeeNumber") AS Employee_ID,
    "PercentSalaryHike" AS Salary_Hike
FROM
    hr
ORDER BY
    "PercentSalaryHike" DESC;

-- This query selects the top 5 employees' IDs ("empno" and "EmployeeNumber" combined) and their corresponding salary hikes ("PercentSalaryHike") 
-- from the table, ordered by salary hike in descending order. In result, we will have the top 5 employees who received the maximum salary hikes 
-- during their last performance review, along with their IDs.

--=============================================================================================================================================================================
-- Functions and Procedures:

-- 1. Create an SQL function that calculates the total working experience of an employee based on their 'Years At Company' and 'Years In Current Role' columns.

CREATE FUNCTION TotalWorkingExperience
(
    @EmployeeNumber INT
)
RETURNS DECIMAL (10,2)
AS
BEGIN
    DECLARE @TotalExperience DECIMAL (10,2)
	SELECT @TotalExperience = YearsAtCompany + YearsInCurrentRole
	FROM HR
	WHERE EmployeeNumber = @EmployeeNumber

	RETURN @TotalExperience
END;

-- Call the function with the appropriate parameter value and correct alias
SELECT DBO.TotalWorkingExperience(10) AS [Total_Working_Experience];


-- The query uses the created function to calculate the total working experience for each employee based on the 'Years At Company' and 
-- 'Years In Current Role' columns from the dataset.

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Write an SQL procedure to update the 'Job Level' of an employee by one level when they receive a performance rating of 5.

CREATE PROCEDURE JobLevelForHighPerformance
    @EmployeeNo INT
AS
BEGIN 
	DECLARE @NewJobLevel INT

SELECT @NewJobLevel = JobLevel + 1
FROM HR
WHERE EmployeeNumber = @EmployeeNo
AND PerformanceRating = 5;

IF @NewJobLevel IS NOT NULL
BEGIN
	UPDATE HR
	SET JobLevel = @NewJobLevel
	WHERE EmployeeNumber = @EmployeeNo;
	END
END;

EXEC JobLevelForHighPerformance @EmployeeNo = 1;

-- There is no employee who's Performance Rating is 5 in the record.

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Design an SQL function that returns the number of employees in a given department with a specific level of job involvement.

CREATE FUNCTION EmployeeCountByJobInvolvement
(
	@Department NVARCHAR(255),
	@JobInvolvement INT
)
RETURNS INT
AS
BEGIN
    DECLARE @EmployeeCount INT;

    SELECT @EmployeeCount = COUNT(*)
    FROM HR
    WHERE Department = @Department
	AND JobInvolvement = @JobInvolvement;

    RETURN @EmployeeCount;
END;

SELECT DBO.EmployeeCountByJobInvolvement ('HR', 2) AS 'No_Of_Employees'

-- Departments in the table are HR, Sales & R&D

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. Create an SQL procedure that generates a unique employee number for new hires and inserts the new employee record into the database.

CREATE PROCEDURE InsertNewEmployee
(
    @empno NVARCHAR(50),
    @JobRole NVARCHAR(50),
    @Age DECIMAL(10,2)
)
AS
BEGIN
    DECLARE @EmployeeNumber INT

    SET @EmployeeNumber = (SELECT ISNULL(MAX(EmployeeNumber), 0) + 1 FROM HR) -- Generate a unique employee number

-- Insert the new employee record

	INSERT INTO HR (empno, JobRole, Age)
    VALUES ('EMP_01', 'HR', 25) 

    SELECT @EmployeeNumber AS 'GeneratedEmployeeNumber'
END;

EXEC InsertNewEmployee 'EMP_01', 'HR', '25';

-- Employee Added in the table at 135 No.

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. Write an SQL function that calculates the average monthly income for employees in a specified age band and department.

CREATE FUNCTION AverageIncomeByAgeAndDepartment
(
    @MinAge INT,
	@MaxAge INT,
    @department NVARCHAR(255)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Avg_income DECIMAL(10, 2);

    SELECT @Avg_income = AVG(MonthlyIncome)
    FROM HR
    WHERE Age BETWEEN @MinAge AND @MaxAge
      AND Department = @department;

    RETURN @Avg_income;
END;

SELECT DBO.AverageIncomeByAgeAndDepartment(35,45, 'Sales') AS 'Average_Monthly_Income';

-- This has calculated the average monthly income for employees who's age is between 35-45 in the Sales department.

--============================================================================================================================================================
-- Triggers

-- 1. Create an SQL trigger that automatically updates the 'Num Companies Worked' column for employees whenever their job satisfaction level is updated,
-- and the new satisfaction level is higher than the previous level. The 'employees' table contains the following relevant columns:
--         	emp_no (INT, PRIMARY KEY): Employee Number
--         	job_satisfaction (INT): Employee's job satisfaction level
--         	num_companies_worked (INT): Number of companies the employee has worked for

-- Write the SQL code to create the trigger and ensure it increments the 'Num Companies Worked' column by one whenever an employee's 
-- job satisfaction level increases during an update.

-- Create a new trigger
CREATE TRIGGER UpdateNumCompaniesWorked
ON HR
AFTER UPDATE
AS
BEGIN
    IF UPDATE(JobSatisfaction)
    BEGIN
        UPDATE HR
        SET NumCompaniesWorked = HR.NumCompaniesWorked + 1
        FROM HR
        INNER JOIN INSERTED i ON HR.empno = i.empno
        INNER JOIN DELETED d ON HR.empno = d.empno
        WHERE i.JobSatisfaction > d.JobSatisfaction;
    END
END;


UPDATE HR
SET JobSatisfaction = 3
WHERE empno = 'STAFF-10';

SELECT *
FROM HR
WHERE empno = 'STAFF-10';

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Create a trigger that updates the 'Environment Satisfaction' to 'High' for all employees in the 'Sales' department when their 'Monthly Income' 
-- exceeds a certain threshold. (Change the threshold with any_value you desired)


-- First we have to Alter the table to change the data type of EnvironmentSatisfaction to VARCHAR.
ALTER TABLE HR
ALTER COLUMN EnvironmentSatisfaction VARCHAR(50);

-- Create the trigger
CREATE TRIGGER UpdateEnvironmentSatisfaction
ON HR
AFTER UPDATE
AS
BEGIN
    DECLARE @Threshold INT
    SET @Threshold = 5000; -- Set your desired threshold here

    IF UPDATE(MonthlyIncome)
    BEGIN
        UPDATE HR
        SET EnvironmentSatisfaction = 'High'
        FROM inserted i
        JOIN HR h ON i.empno = h.empno
        WHERE i.Department = 'Sales'
        AND i.MonthlyIncome > @Threshold;
    END
END;


UPDATE HR
SET MonthlyIncome = 5993
WHERE Department = 'Sales' AND empno = 'STAFF-1';

SELECT *
FROM HR
WHERE Empno = 'STAFF-1';
