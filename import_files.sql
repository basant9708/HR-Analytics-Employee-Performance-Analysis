--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
-----------------------------------------------------------HR-Analytics-Employee-Performance-Analysis-----------------------------------------------------------
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
/*
HR-Analytics-Employee-Performance-Analysis/
│
├── data/
│   ├── 01_Employees.csv
│   ├── 02_Departments.csv
│   ├── 03_Job_Roles.csv
│   ├── 04_Locations.csv
│   ├── 05_Salaries.csv
│   ├── 06_Attendance.csv
│   ├── 07_Performance.csv
│   ├── 08_Training.csv
│   ├── 09_Promotions.csv
│   └── 10_Employee_Exit.csv


*/
-- =============================================================================================================================================================
-- 1. Employees Table
-- =============================================================================================================================================================

CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    gender VARCHAR(10),
    date_of_birth DATE,
    age INT,
    marital_status VARCHAR(20),
    department_id INT,
    job_role_id INT,
    manager_id INT,
    location_id INT,
    hire_date DATE,
    employment_status VARCHAR(20),
    education_level VARCHAR(50),
    experience_years INT
);

-- =========================================
-- Employees Data Import
-- =========================================

COPY employees (
    employee_id,
    employee_name,
    gender,
    date_of_birth,
    age,
    marital_status,
    department_id,
    job_role_id,
    manager_id,
    location_id,
    hire_date,
    employment_status,
    education_level,
    experience_years
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Employees.csv'
DELIMITER ','
CSV HEADER;


SELECT * FROM employees;


-- =============================================================================================================================================================
-- 2. Departments Table
-- =============================================================================================================================================================

CREATE TABLE departments (
    department_id INT,
    department_name VARCHAR(50),
    department_head VARCHAR(100)
);

-- =========================================
--  Departments Data Import
-- =========================================

COPY departments (
    department_id,
    department_name,
    department_head
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Departments.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM departments;


-- =============================================================================================================================================================
-- 3. Job Roles Table
-- =============================================================================================================================================================

CREATE TABLE job_roles (
    job_role_id INT,
    job_role_name VARCHAR(100),
    department_id INT,
    job_level VARCHAR(20)
);


-- =========================================
-- Job Roles Data Import
-- =========================================

COPY job_roles (
    job_role_id,
    job_role_name,
    department_id,
    job_level
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Job_Roles.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM job_roles;


-- ==============================================================================================================================================================
-- 4. Locations Table
-- ==============================================================================================================================================================

CREATE TABLE locations (
    location_id INT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

-- =========================================
-- Locations Data Import
-- =========================================

COPY locations (
    location_id,
    city,
    state,
    country
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Locations.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM locations;


-- =============================================================================================================================================================
-- 5. Salaries Table
-- =============================================================================================================================================================

CREATE TABLE salaries (
    salary_id INT,
    employee_id INT,
    salary DECIMAL(12,2),
    bonus DECIMAL(12,2),
    salary_grade VARCHAR(5),
    effective_date DATE,
    increment_percentage DECIMAL(5,2)
);

-- =========================================
-- Salaries Data Import
-- =========================================

COPY salaries (
    salary_id,
    employee_id,
    salary,
    bonus,
    salary_grade,
    effective_date,
    increment_percentage
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Salaries.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM salaries;


-- =============================================================================================================================================================
-- 6 .Attendance Table
-- =============================================================================================================================================================
CREATE TABLE attendance (
    attendance_id INT ,
    employee_id INT,
    attendance_date DATE,
    attendance_status VARCHAR(20),
    working_hours DECIMAL(4,2),
    overtime_hours DECIMAL(4,2)
);

-- =========================================
-- Attendance Data Import
-- =========================================

COPY
attendance (
attendance_id,
employee_id,
attendance_date,
attendance_status,
working_hours,
overtime_hours
)
from 'D:\project_for_data_analyst\HR Analytics\same_data\Attendance.csv'
delimiter','
csv header;

SELECT * FROM attendance;


-- ==============================================================================================================================================================
-- 7. Performance Table
-- ==============================================================================================================================================================

CREATE TABLE performance (
    performance_id INT,
    employee_id INT,
    review_date DATE,
    performance_rating INT,
    productivity_score INT,
    quality_score INT,
    manager_rating INT,
    employee_rating INT
);


-- =========================================
-- Performance Data Import
-- =========================================

COPY performance (
    performance_id,
    employee_id,
    review_date,
    performance_rating,
    productivity_score,
    quality_score,
    manager_rating,
    employee_rating
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Performance.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM performance;



-- ===============================================================================================================================================================
-- 8. Training Table
-- ===============================================================================================================================================================

CREATE TABLE training (
    training_id INT,
    employee_id INT,
    training_name VARCHAR(100),
    training_category VARCHAR(50),
    training_date DATE,
    training_hours INT,
    training_cost DECIMAL(12,2),
    completion_status VARCHAR(20),
    training_score INT
);


-- =========================================
-- Training Data Import
-- =========================================

COPY training (
    training_id,
    employee_id,
    training_name,
    training_category,
    training_date,
    training_hours,
    training_cost,
    completion_status,
    training_score
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Training.csv'
DELIMITER ','
CSV HEADER;


SELECT * FROM training;




-- ==============================================================================================================================================================
-- 9. Promotions Table
-- ==============================================================================================================================================================

CREATE TABLE promotions (
    promotion_id INT,
    employee_id INT,
    previous_job_role_id INT,
    new_job_role_id INT,
    promotion_date DATE,
    previous_salary DECIMAL(12,2),
    new_salary DECIMAL(12,2)
);

-- =========================================
-- Promotions Data Import
-- =========================================

COPY promotions (
    promotion_id,
    employee_id,
    previous_job_role_id,
    new_job_role_id,
    promotion_date,
    previous_salary,
    new_salary
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Promotions.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM promotions;


-- ==============================================================================================================================================================
-- 10. Employee Exit Table
-- ==============================================================================================================================================================

CREATE TABLE employee_exit (
    exit_id INT,
    employee_id INT,
    exit_date DATE,
    exit_reason VARCHAR(50),
    exit_type VARCHAR(20),
    notice_period_days INT,
    employee_satisfaction_score DECIMAL(2,1)
);


-- =========================================
-- Employee Exit Data Import
-- =========================================

COPY employee_exit (
    exit_id,
    employee_id,
    exit_date,
    exit_reason,
    exit_type,
    notice_period_days,
    employee_satisfaction_score
)
FROM 'D:\project_for_data_analyst\HR Analytics\same_data\Employee_Exit.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM employee_exit;




