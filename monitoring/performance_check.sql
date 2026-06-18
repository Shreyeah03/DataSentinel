-- ============================================================
-- MySQL DBA Project
-- File: performance_check.sql
-- Description: SQL queries for performance analysis,
--              indexing, and query optimization
-- ============================================================

USE emp_management;

-- -------------------------------------------------------
-- 1. CHECK EXISTING INDEXES ON ALL TABLES
-- -------------------------------------------------------
SELECT 'Checking existing indexes...' AS Info;

SHOW INDEX FROM employees;
SHOW INDEX FROM departments;
SHOW INDEX FROM attendance;

-- -------------------------------------------------------
-- 2. ADD PERFORMANCE INDEXES
-- -------------------------------------------------------

-- Index on email for fast login/lookup queries
CREATE INDEX IF NOT EXISTS idx_emp_email
    ON employees(email);

-- Index on dept_id for fast JOIN queries
CREATE INDEX IF NOT EXISTS idx_emp_dept
    ON employees(dept_id);

-- Composite index on attendance for date range queries
CREATE INDEX IF NOT EXISTS idx_attendance_emp_date
    ON attendance(emp_id, check_in);

SELECT 'Indexes created successfully!' AS Status;

-- -------------------------------------------------------
-- 3. ANALYZE QUERY WITH EXPLAIN (Performance Check)
-- -------------------------------------------------------
SELECT 'Analyzing query performance with EXPLAIN...' AS Info;

-- Check how MySQL executes a JOIN query
EXPLAIN
SELECT
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 60000;

-- -------------------------------------------------------
-- 4. USEFUL BUSINESS QUERIES (showcase SQL skills)
-- -------------------------------------------------------

-- Average salary by department
SELECT
    d.dept_name,
    COUNT(e.emp_id)         AS total_employees,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    MAX(e.salary)           AS max_salary,
    MIN(e.salary)           AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

-- Attendance summary per employee (present/absent/leave count)
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
    SUM(CASE WHEN a.status = 'Absent'  THEN 1 ELSE 0 END) AS absent_days,
    SUM(CASE WHEN a.status = 'Leave'   THEN 1 ELSE 0 END) AS leave_days,
    COUNT(a.attendance_id)                                 AS total_records
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, employee_name
ORDER BY present_days DESC;

-- -------------------------------------------------------
-- 5. CHECK TABLE STATUS (fragmentation & optimization)
-- -------------------------------------------------------
SELECT
    table_name,
    engine,
    table_rows,
    ROUND(data_length / 1024, 2)    AS data_kb,
    ROUND(index_length / 1024, 2)   AS index_kb,
    ROUND(data_free / 1024, 2)      AS free_kb
FROM information_schema.tables
WHERE table_schema = 'emp_management';

-- -------------------------------------------------------
-- 6. OPTIMIZE TABLES (reclaim fragmented space)
-- -------------------------------------------------------
OPTIMIZE TABLE employees;
OPTIMIZE TABLE attendance;

SELECT 'Performance check complete!' AS Status;
