--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--******************************************************HR Analytics & Employee Performance Analysis****************************************************
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
/*Business SQL Analysis Project — 17 Questions with Query Solutions
HR Analytics & Employee Performance Analysis
Business SQL Analysis Project
Database Dialect: PostgreSQL Tables Used: Employees, Departments, Job_Roles, Locations, 
Salaries, Attendance, Performance, Training, Promotions, Employee_Exit*/
 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*Section 1: Executive Summary*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
/*Question 1 — What is the overall health of the company’s workforce?

Objective: Calculate, in a single result, the company’s core workforce KPIs — 
Total Employees, Active Employees, Attrition Rate, Average Salary, Average Experience, Average Performance Rating, and Average Employee Satisfaction.

Tables: Employees, Salaries, Performance, Employee_Exit SQL Concepts: Conditional Aggregation, JOIN, Aggregate Functions*/
-- =====================================================================================================================================================
-- Overall Workforce Health - KPI Summary
-- =====================================================================================================================================================



SELECT
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (
        WHERE employment_status = 'Active'
    ) AS active_employees,
    ROUND(
        COUNT(*) FILTER (
            WHERE employment_status IN ('Resigned', 'Terminated', 
'Retired')
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate,
    ROUND((SELECT AVG(salary) FROM salaries), 2)
        AS average_salary,
    ROUND(AVG(experience_years), 2)
        AS average_experience,
    ROUND((SELECT AVG(performance_rating) FROM performance), 2)
        AS average_performance_rating,
    ROUND((SELECT AVG(employee_satisfaction_score) FROM employee_exit), 2)
        AS average_employee_satisfaction
FROM employees;


/* 
Business Insight: This single query acts as the company’s HR dashboard “at a glance” — the kind of number set a CHRO or CEO would want before any meeting.
A rising attrition rate or a falling average performance rating here is an early signal that deeper analysis (Sections 2–5) is needed.
 */


 
 --*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



/*Section 2: Employee Cost & Workforce Efficiency
Question 2 — What is the company’s total employee-related cost?
Objective: Calculate combined Salary, Bonus, and Training Cost, and show the percentage contribution of each component.
Tables: Salaries, Training SQL Concepts: JOIN, Aggregation, CTE
*/
WITH salary_data AS (
    SELECT
        SUM(salary) AS total_salary,
        SUM(bonus)  AS total_bonus
    FROM salaries
),
training_data AS (
    SELECT
        SUM(training_cost) AS total_training_cost
    FROM training
),
combined_data AS (
    SELECT
        s.total_salary,
        s.total_bonus,
        t.total_training_cost,
        s.total_salary + s.total_bonus + t.total_training_cost
            AS total_employee_cost
    FROM salary_data s
    CROSS JOIN training_data t
)
SELECT     total_salary,     total_bonus,     total_training_cost,     total_employee_cost,
    ROUND(total_salary * 100.0 / total_employee_cost, 2)
        AS salary_contribution_pct,
    ROUND(total_bonus * 100.0 / total_employee_cost, 2)
        AS bonus_contribution_pct,
    ROUND(total_training_cost * 100.0 / total_employee_cost, 2)
        AS training_cost_contribution_pct
FROM combined_data;

/*
Business Insight: Shows leadership exactly where the HR budget is going. 
If training cost is a very small % of total cost, it may indicate under-investment in employee development relative to fixed compensation costs.
 */


 
 --*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


/*
Question 3 — Which departments have the highest overtime hours, and does higher overtime correspond to better performance?
Objective: For each department, calculate Total Overtime Hours, Average Overtime per Employee, and Average Performance Rating,
then flag departments where overtime is high but performance is comparatively low.
Tables: Employees, Departments, Attendance, Performance SQL Concepts: JOIN, GROUP BY, CTE, CASE
*/



WITH overtime_data AS (
    SELECT
        e.department_id,
        SUM(a.overtime_hours) AS total_overtime_hours,
        SUM(a.overtime_hours) / COUNT(DISTINCT e.employee_id)
            AS avg_overtime_per_employee
    FROM employees e
    INNER JOIN attendance a ON e.employee_id = a.employee_id
    GROUP BY e.department_id
),
performance_data AS (
    SELECT
        e.department_id,
        AVG(p.performance_rating) AS avg_performance_rating
    FROM employees e
    INNER JOIN performance p ON e.employee_id = p.employee_id
    GROUP BY e.department_id
)
SELECT
    d.department_id,
    d.department_name,
    o.total_overtime_hours,
    ROUND(o.avg_overtime_per_employee, 2) AS avg_overtime_per_employee,
    ROUND(p.avg_performance_rating, 2)    AS avg_performance_rating,
    CASE
        WHEN o.avg_overtime_per_employee > (SELECT 
AVG(avg_overtime_per_employee) FROM overtime_data)          AND p.avg_performance_rating   < (SELECT 
AVG(avg_performance_rating)   FROM performance_data)
            THEN 'High Overtime - Low Performance'
        WHEN o.avg_overtime_per_employee > (SELECT 
AVG(avg_overtime_per_employee) FROM overtime_data)          AND p.avg_performance_rating  >= (SELECT 
AVG(avg_performance_rating)   FROM performance_data)
            THEN 'High Overtime - High Performance'
        ELSE 'Normal / Low Overtime'
    END AS overtime_performance_category
FROM departments d
INNER JOIN overtime_data     o ON d.department_id = o.department_id
INNER JOIN performance_data  p ON d.department_id = p.department_id ORDER BY o.total_overtime_hours DESC;



/*
Business Insight: Departments tagged “High Overtime – Low Performance” may indicate workload pressure,
understaffing, or inefficient processes rather than genuine productivity. Departments tagged “High Overtime –
High Performance” are likely converting extra hours into real output — but should still be monitored for burnout risk.
*/



--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


 /*
Question 4 — How long does it take employees to receive their first promotion, and how much does their salary increase?


Objective: For promoted employees, calculate average time to first promotion, previous/new salary, average salary increase %, 
and department-wise promotion timelines.
Tables: Employees, Promotions, Job_Roles, Departments SQL Concepts: MIN, Date Functions, CTE, Window Functions
*/


WITH ranked_promotions AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY p.employee_id
            ORDER BY p.promotion_date
        ) AS rn
    FROM promotions p
),
first_promotion AS (
    SELECT
        e.employee_id,
        e.employee_name,
        d.department_name,
        e.hire_date,
        rp.promotion_date AS first_promotion_date,         rp.previous_salary,         rp.new_salary
    FROM employees e
    INNER JOIN ranked_promotions rp
        ON e.employee_id = rp.employee_id AND rp.rn = 1
    INNER JOIN departments d ON e.department_id = d.department_id
),
promotion_data AS (
    SELECT         *,
        first_promotion_date - hire_date AS days_to_first_promotion,
        ROUND((first_promotion_date - hire_date) / 365.25, 2)
            AS years_to_first_promotion,
        ROUND((new_salary - previous_salary) * 100.0 / 
NULLIF(previous_salary, 0), 2)
            AS salary_increase_pct
    FROM first_promotion
)
SELECT     employee_id,     employee_name,     department_name,     days_to_first_promotion,     years_to_first_promotion,     previous_salary,     new_salary,     salary_increase_pct,
    ROUND(AVG(years_to_first_promotion) OVER (PARTITION BY department_name), 2)
        AS department_avg_promotion_years
FROM promotion_data
ORDER BY department_name, years_to_first_promotion;



/*
Business Insight: Departments with a much longer average time-to-promotion may be
at higher risk of losing ambitious employees to competitors who promote faster. 
This informs career-pathing and internal-mobility policy.
 */
 
 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-Section 3: Attrition Analysis*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


/*Question 5 — Why are employees leaving the company?
Objective: Find the most common exit reasons, their counts, percentage of total exits, and average satisfaction score per reason.
Tables: Employee_Exit, Employees SQL Concepts: GROUP BY, COUNT, Percentage Calculation, ORDER BY
*/



SELECT
    ee.exit_reason,
    COUNT(*) AS number_of_employees,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employee_exit), 2)
        AS percentage_of_total_exits,
    ROUND(AVG(ee.employee_satisfaction_score), 2)
        AS average_satisfaction_score
FROM employee_exit ee
INNER JOIN employees e ON ee.employee_id = e.employee_id
GROUP BY ee.exit_reason
ORDER BY number_of_employees DESC;
/*
Business Insight: If “Salary” or “Better Opportunity” dominates the exit reasons, it signals a compensation competitiveness problem.
If “Management” or “Work Environment” leads, it points to a culture or leadership issue rather than a pay issue — each requires a
completely different fix.
*/

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

 /*
Question 6 — Are we losing our best-performing employees?
Objective: Compare exited employees against their performance history; identify how many high performers (rating 4–5) left, 
and compare average performance of exited vs. active employees.
Tables: Performance, Employee_Exit, Employees SQL Concepts: JOIN, CASE, CTE, Conditional Aggregation
*/


WITH employee_performance AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.employment_status,
        AVG(p.performance_rating) AS average_performance_rating
    FROM employees e
    INNER JOIN performance p ON e.employee_id = p.employee_id
    GROUP BY e.employee_id, e.employee_name, e.employment_status
),
performance_status AS ( SELECT employee_id, employee_name,  employment_status,   average_performance_rating,
        CASE
            WHEN average_performance_rating >= 4 THEN 'High Performer'
            ELSE 'Not High Performer'
        END AS performer_category
    FROM employee_performance
)
SELECT
    COUNT(*) FILTER (
        WHERE employment_status IN ('Resigned', 'Terminated', 
'Retired')
          AND performer_category = 'High Performer'
    ) AS high_performers_who_left,
    ROUND(
        COUNT(*) FILTER (
            WHERE employment_status IN ('Resigned', 'Terminated', 
'Retired')
              AND performer_category = 'High Performer'
        ) * 100.0
        / NULLIF(COUNT(*) FILTER (
            WHERE employment_status IN ('Resigned', 'Terminated', 
'Retired')
        ), 0),
        2
    ) AS high_performer_exit_percentage,
    ROUND(AVG(average_performance_rating) FILTER (
        WHERE employment_status IN ('Resigned', 'Terminated', 
'Retired')
    ), 2) AS avg_performance_exited_employees,
    ROUND(AVG(average_performance_rating) FILTER (
        WHERE employment_status = 'Active'
    ), 2) AS avg_performance_active_employees
FROM performance_status;



/*
Business Insight: This is the “regretted attrition” metric — the most expensive kind of employee loss. 
A high high_performer_exit_percentage means the company is losing its best talent, not just its weakest, 
and needs an urgent retention strategy for top performers.
 */

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 
 /*
Question 7 — Which departments have the highest employee attrition?
Objective: Calculate department-wise Total Employees, Employees Who Left, and Attrition Rate, then flag departments above the company-wide average.
Tables: Employees, Departments, Employee_Exit SQL Concepts: LEFT JOIN, GROUP BY, HAVING, CTE
*/


WITH department_data AS (
    SELECT
        d.department_id,
        d.department_name,
        COUNT(DISTINCT e.employee_id)  AS total_employees,
        COUNT(DISTINCT ee.employee_id) AS employees_who_left
    FROM departments d
    LEFT JOIN employees e      ON d.department_id = e.department_id
    LEFT JOIN employee_exit ee ON e.employee_id = ee.employee_id
    GROUP BY d.department_id, d.department_name
),
attrition_data AS ( SELECT department_id,  department_name, total_employees, employees_who_left,
        ROUND(employees_who_left * 100.0 / NULLIF(total_employees, 0), 
2)
            AS attrition_rate
    FROM department_data
),
company_attrition AS (
    SELECT
        ROUND(SUM(employees_who_left) * 100.0 / 
NULLIF(SUM(total_employees), 0), 2)
            AS company_attrition_rate
    FROM department_data
)
SELECT
    a.department_id,
    a.department_name,
    a.total_employees,
    a.employees_who_left,
    a.attrition_rate,
    c.company_attrition_rate FROM attrition_data a
CROSS JOIN company_attrition c
WHERE a.attrition_rate > c.company_attrition_rate
ORDER BY a.attrition_rate DESC;

/*
Business Insight: Pinpoints exactly which departments need focused retention budget and leadership attention, 
rather than applying a one-size-fits-all HR policy across the whole company.
*/

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


/* 
Question 8 — Which experience group has the highest attrition risk?
Objective: Group employees into experience bands (0–1, 2–4, 5–9, 10+ years) and calculate attrition rate per band.
Tables: Employees, Employee_Exit SQL Concepts: CASE, GROUP BY, CTE
*/



WITH experience_group AS (
    SELECT
        e.employee_id,
        e.experience_years,
        CASE
            WHEN e.experience_years BETWEEN 0 AND 1 THEN '0-1 Years'
            WHEN e.experience_years BETWEEN 2 AND 4 THEN '2-4 Years'
            WHEN e.experience_years BETWEEN 5 AND 9 THEN '5-9 Years'
            WHEN e.experience_years >= 10 THEN '10+ Years'
        END AS experience_group
    FROM employees e
),
attrition_data AS (     SELECT
        eg.experience_group,
        COUNT(DISTINCT eg.employee_id)  AS total_employees,
        COUNT(DISTINCT ee.employee_id)  AS employees_who_left
    FROM experience_group eg
    LEFT JOIN employee_exit ee ON eg.employee_id = ee.employee_id
    GROUP BY eg.experience_group
)
SELECT
    experience_group,     total_employees,     employees_who_left,
    ROUND(employees_who_left * 100.0 / NULLIF(total_employees, 0), 2)
        AS attrition_rate
FROM attrition_data
ORDER BY attrition_rate DESC;



/*
Business Insight: If early-career employees (0–1 years) show the highest attrition,
it points to onboarding or hiring-fit problems. If it’s the 5–9 year group, it usually signals a “career plateau” —
experienced employees leaving because they see no further growth path.
 */

 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-Section 4: Manager & Team Effectiveness-*-*-*-*-*-*-*--*-*-*-*-*-*-*--*-*-*-*-*-*-*--*-*-*-*-*-*-*-


/*Question 9 — Which managers have the highest team attrition?
Objective: For every manager, calculate team size, employees who left, and attrition rate; rank managers from highest to lowest attrition.
Tables: Employees, Employee_Exit SQL Concepts: SELF JOIN, CTE, RANK/DENSE_RANK */

WITH team_data AS (
    SELECT
        m.employee_id   AS manager_id,
        m.employee_name AS manager_name,
        COUNT(DISTINCT e.employee_id)  AS team_size,
        COUNT(DISTINCT ee.employee_id) AS employees_who_left
    FROM employees m
    INNER JOIN employees e      ON e.manager_id = m.employee_id
    LEFT JOIN employee_exit ee  ON e.employee_id = ee.employee_id
    GROUP BY m.employee_id, m.employee_name
)
SELECT     manager_id,     manager_name,     team_size,     employees_who_left,
    ROUND(employees_who_left * 100.0 / NULLIF(team_size, 0), 2)
        AS attrition_rate,
    RANK() OVER (
        ORDER BY employees_who_left * 1.0 / NULLIF(team_size, 0) DESC
    ) AS attrition_rank
FROM team_data
WHERE team_size >= 5          -- ignore very small teams for statistical reliability ORDER BY attrition_rate DESC;


/*
Business Insight: Managers who consistently rank at the top of this list across review periods may need coaching, 
or their management style may be actively driving people out — this is one of the strongest “leading indicators” HR can track.
 */


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

 
 
 /*
Question 10 — Which managers lead the highest-performing teams?
Objective: Calculate manager-wise team size, average performance rating, average productivity score, and average quality score;
rank managers accordingly. Tables: Employees, Performance SQL Concepts: SELF JOIN, GROUP BY, RANK
*/


WITH team_performance AS (
    SELECT
        m.employee_id   AS manager_id,
        m.employee_name AS manager_name,
        COUNT(DISTINCT e.employee_id) AS team_size,
        AVG(p.performance_rating)     AS avg_performance_rating,
        AVG(p.productivity_score)     AS avg_productivity_score,
        AVG(p.quality_score)          AS avg_quality_score
    FROM employees m
    INNER JOIN employees e   ON e.manager_id = m.employee_id
    INNER JOIN performance p ON p.employee_id = e.employee_id
    GROUP BY m.employee_id, m.employee_name
)
SELECT     manager_id,     manager_name,     team_size,
    ROUND(avg_performance_rating, 2) AS avg_performance_rating,
    ROUND(avg_productivity_score, 2) AS avg_productivity_score,
    ROUND(avg_quality_score, 2)      AS avg_quality_score,     RANK() OVER (ORDER BY avg_performance_rating DESC) AS performance_rank FROM team_performance
WHERE team_size >= 5
ORDER BY avg_performance_rating DESC;




/*
Business Insight: High-ranking managers here are strong candidates for mentoring other managers, taking on larger teams,
or being studied for “what they do differently” — a bestpractice playbook can be built from their approach.
 */


 
 --*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-Section 5: Salary, Growth & Retention-*-*-*-*-*-*-*--*-*-*-*-*-*-*--*-*-*-*-*-*-*--*-*-*-*-*-*-*-


/*
Question 11 — Which job roles have the largest salary differences between employees?
Objective: For each job role, calculate min, max, average salary, and the salary range (gap).
Tables: Employees, Job_Roles, Salaries SQL Concepts: MIN, MAX, AVG, GROUP BY, JOIN
*/



SELECT jr.job_role_id, jr.job_role_name,
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    MIN(s.salary)        AS min_salary,
    MAX(s.salary)         AS max_salary,
    ROUND(AVG(s.salary), 2) AS avg_salary,
    MAX(s.salary) - MIN(s.salary) AS salary_range
FROM job_roles jr
INNER JOIN employees e   ON e.job_role_id = jr.job_role_id
INNER JOIN salaries s    ON s.employee_id = e.employee_id
INNER JOIN departments d ON d.department_id = jr.department_id
GROUP BY jr.job_role_id, jr.job_role_name, d.department_name ORDER BY salary_range DESC;



/*
Business Insight: A very large salary range within the same role is a pay-equity red flag —
it can mean inconsistent hiring negotiation, outdated salary bands, or discrimination risk, and is usually one of the first things an HR audit checks.
 */


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


 /*
Question 12 — Which employees could be considered flight risks?
Objective: Identify employees with more than 2 years of tenure, high performance ratings (4– 5), no promotion history, and comparatively low salary increments.
Tables: Employees, Salaries, Performance, Promotions SQL Concepts: CTE, LEFT JOIN, NOT EXISTS / Subquery, CASE
*/


WITH promoted_employees AS (
    SELECT DISTINCT employee_id FROM promotions
),
employee_perf AS (     SELECT         employee_id,
        AVG(performance_rating) AS avg_rating
    FROM performance
    GROUP BY employee_id
)
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,     jr.job_role_name,
    e.experience_years,
    s.salary,
    ROUND(ep.avg_rating, 2)     AS avg_performance_rating,
    s.increment_percentage
FROM employees e
INNER JOIN departments d ON d.department_id = e.department_id
INNER JOIN job_roles jr  ON jr.job_role_id = e.job_role_id
INNER JOIN salaries s    ON s.employee_id = e.employee_id
INNER JOIN employee_perf ep ON ep.employee_id = e.employee_id
WHERE e.employment_status = 'Active'
  AND e.experience_years > 2
  AND ep.avg_rating >= 4
  AND e.employee_id NOT IN (SELECT employee_id FROM promoted_employees)
  AND s.increment_percentage < (SELECT AVG(increment_percentage) FROM salaries)
ORDER BY ep.avg_rating DESC, e.experience_years DESC;



/*
Business Insight: This query produces a ready-to-use watch-list.
These are strong, tenured performers who have been “overlooked” on pay and promotion —
statistically the group most likely to resign for a better offer elsewhere. Proactive retention conversations here are far cheaper than replacing them.
 */

 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

 /*
Question 13 — Does employee training improve performance?
Objective: Compare average performance ratings before and after completed training, and identify which training category shows the greatest improvement.
Tables: Training, Performance, Employees SQL Concepts: CTE, CASE, Date Functions, JOIN
*/


WITH training_events AS (
    SELECT employee_id, training_category, training_date
    FROM training
    WHERE completion_status = 'Completed'
),
perf_before AS (     SELECT
        te.employee_id, te.training_category, te.training_date,
        AVG(p.performance_rating) AS avg_before
    FROM training_events te
    INNER JOIN performance p
        ON p.employee_id = te.employee_id
       AND p.review_date < te.training_date
    GROUP BY te.employee_id, te.training_category, te.training_date
),
perf_after AS (     SELECT
        te.employee_id, te.training_category, te.training_date,
        AVG(p.performance_rating) AS avg_after
    FROM training_events te
    INNER JOIN performance p
        ON p.employee_id = te.employee_id
       AND p.review_date >= te.training_date
    GROUP BY te.employee_id, te.training_category, te.training_date
)
SELECT
    b.training_category,
    ROUND(AVG(b.avg_before), 2) AS avg_performance_before,
    ROUND(AVG(a.avg_after), 2)  AS avg_performance_after,     ROUND(AVG(a.avg_after) - AVG(b.avg_before), 2) AS performance_change FROM perf_before b
INNER JOIN perf_after a
    ON a.employee_id = b.employee_id
   AND a.training_date = b.training_date
   AND a.training_category = b.training_category
GROUP BY b.training_category
ORDER BY performance_change DESC;



/*
Business Insight: Categories with the biggest positive performance_change justify continued (or increased) training investment. 
Categories with flat or negative change suggest the current curriculum or delivery method for that topic isn’t working and should be redesigned.
 */

 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

 
 /*
Question 14 — Do promoted employees stay longer with the company?
Objective: Compare promoted vs. never-promoted employees on number of employees, attrition rate, and average tenure.
Tables: Employees, Promotions, Employee_Exit SQL Concepts: CTE, LEFT JOIN, CASE, Aggregation
*/



WITH promoted AS (
    SELECT DISTINCT employee_id FROM promotions
),
emp_status AS (
    SELECT
        e.employee_id,
        e.hire_date,
        e.employment_status,
        CASE WHEN p.employee_id IS NOT NULL THEN 'Promoted' ELSE 'Not 
Promoted' END
            AS promotion_group,
        COALESCE(ee.exit_date, CURRENT_DATE) AS end_date
    FROM employees e
    LEFT JOIN promoted p       ON p.employee_id = e.employee_id
    LEFT JOIN employee_exit ee ON ee.employee_id = e.employee_id
)
SELECT
    promotion_group,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE employment_status != 'Active') AS employees_left,
    ROUND(
        COUNT(*) FILTER (WHERE employment_status != 'Active') * 100.0 
/ COUNT(*),
        2
    ) AS attrition_rate,
    ROUND(AVG((end_date - hire_date) / 365.25), 2) AS avg_tenure_years
FROM emp_status
GROUP BY promotion_group;


/*
Business Insight: If “Not Promoted” employees show meaningfully higher attrition and lower average tenure,
it proves — with data, not opinion — that promotion pathways are a direct retention lever,
strengthening the business case for investing in internal mobility.
 */


 --===================================================Section 6: Attendance, Training & Diversity=========================================================



/*Question 15 — Which departments and locations have the highest absenteeism?
Objective: Calculate the % breakdown of attendance status (Present, Absent, Leave, WFH), plus average working and overtime hours, by department and location.
Tables: Attendance, Employees, Departments, Locations SQL Concepts: CASE, Conditional Aggregation, GROUP BY
*/


WITH attendance_summary AS (
    SELECT
        e.department_id,
        e.location_id,
        COUNT(*) AS total_records,
        COUNT(*) FILTER (WHERE a.attendance_status = 'Present') 
AS present_count,
        COUNT(*) FILTER (WHERE a.attendance_status = 'Absent') 
AS absent_count,
        COUNT(*) FILTER (WHERE a.attendance_status = 'Leave') 
AS leave_count,
        COUNT(*) FILTER (WHERE a.attendance_status = 'Work From Home') 
AS wfh_count,
        AVG(a.working_hours) AS avg_working_hours,
        AVG(a.overtime_hours) AS avg_overtime_hours
    FROM attendance a
    INNER JOIN employees e ON e.employee_id = a.employee_id
    GROUP BY e.department_id, e.location_id
)
SELECT
    d.department_name,
    l.city,
    l.state,     total_records,
    ROUND(present_count * 100.0 / total_records, 2) AS present_pct,
    ROUND(absent_count  * 100.0 / total_records, 2) AS absent_pct,
    ROUND(leave_count   * 100.0 / total_records, 2) AS leave_pct,
    ROUND(wfh_count      * 100.0 / total_records, 2) AS wfh_pct,
    ROUND(avg_working_hours, 2)  AS avg_working_hours,
    ROUND(avg_overtime_hours, 2) AS avg_overtime_hours
FROM attendance_summary a
INNER JOIN departments d ON d.department_id = a.department_id
INNER JOIN locations l   ON l.location_id = a.location_id ORDER BY absent_pct DESC;


/*
Business Insight: Locations or departments with unusually high absenteeism may be facing engagement, 
health, or commute/infrastructure issues (e.g., a specific city office) —
this narrows down where a site-visit or an engagement survey should be prioritized.
 */

 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

 
 /*
Question 16 — Where is the training budget being spent, and which training categories have low completion?
Objective: For each training category, calculate total cost, program count, average cost, completion rate, and average training score — flag categories with high spend but low completion.
Tables: Training, Employees SQL Concepts: GROUP BY, CASE, CTE, HAVING
*/



SELECT
    training_category,
    COUNT(*)                    AS number_of_programs,
    SUM(training_cost)          AS total_training_cost,
    ROUND(AVG(training_cost), 2) AS avg_training_cost,
    ROUND(
        COUNT(*) FILTER (WHERE completion_status = 'Completed') * 
100.0 / COUNT(*),
        2
    ) AS completion_rate,
    ROUND(
        AVG(training_score) FILTER (WHERE completion_status = 
'Completed'),
        2
    ) AS avg_training_score
FROM training
GROUP BY training_category
HAVING SUM(training_cost) > (
    SELECT AVG(cat_cost)
    FROM (
        SELECT SUM(training_cost) AS cat_cost
        FROM training
        GROUP BY training_category
    ) t
)
ORDER BY completion_rate ASC;
/*
Business Insight: This query surfaces categories where the company is spending aboveaverage money but getting below-average completion 
— a direct, quantified case for either redesigning that training program or reallocating its budget elsewhere.
 */


 
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



 /*
Question 17 — How diverse is the company’s leadership team?
Objective: Analyze gender representation among Manager and Director-level employees, overall and by department.
Tables: Employees, Job_Roles, Departments SQL Concepts: JOIN, CASE, Conditional Aggregation, GROUP BY
*/




WITH leadership AS (
    SELECT
        e.employee_id,
        e.gender,
        d.department_name
    FROM employees e
    INNER JOIN job_roles jr  ON jr.job_role_id = e.job_role_id
    INNER JOIN departments d ON d.department_id = e.department_id
    WHERE jr.job_level IN ('Manager', 'Director')
)
SELECT
    department_name,
    COUNT(*) AS total_leaders,
    COUNT(*) FILTER (WHERE gender = 'Male')   AS male_leaders,
    COUNT(*) FILTER (WHERE gender = 'Female') AS female_leaders,
    ROUND(COUNT(*) FILTER (WHERE gender = 'Male')   * 100.0 / 
COUNT(*), 2) AS male_pct,
    ROUND(COUNT(*) FILTER (WHERE gender = 'Female') * 100.0 / 
COUNT(*), 2) AS female_pct
FROM leadership
GROUP BY department_name
ORDER BY total_leaders DESC;

/*
Business Insight: A skewed leadership gender split in specific departments is a key input for
DEI (Diversity, Equity & Inclusion) reporting and succession-planning decisions — increasingly a metric that boards, investors, 
and ESG reports require.
 */

/* 
#	Question	Key SQL Concepts
1	Overall workforce health (Executive Summary)	Conditional Aggregation, JOIN
2	Total employee-related cost	CTE, Aggregation
3	Overtime vs. performance by department	CTE, CASE
4	Time to first promotion & salary increase	Window Functions, CTE
5	Reasons employees leave	GROUP BY, Percentage Calc
6	Losing best performers?	CASE, Conditional Aggregation
7	Department-wise attrition vs. company average	HAVING, CTE
8	Attrition by experience group	CASE, GROUP BY
9	Manager-wise attrition 	SELF JOIN, RANK
Appendix: Question Index
#	Question ranking	Key SQL Concepts
10	Manager-wise performance ranking	SELF JOIN, RANK
11	Salary range by job role	MIN/MAX/AVG, GROUP BY
12	Flight-risk employees	CTE, NOT IN / Subquery
13	Training impact on performance	CTE, Date Comparison
14	Promoted vs. non-promoted retention	CTE, CASE
15	Absenteeism by department/location	Conditional Aggregation
16	Training budget vs. completion rate	HAVING, Subquery
17	Leadership gender diversity	CASE, Conditional Aggregation
Prepared as part of the HR Analytics & Employee Performance Analysis portfolio project.
*/
