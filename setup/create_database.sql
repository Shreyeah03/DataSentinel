-- ============================================================
-- MySQL DBA Project: Employee Management System
-- File: create_database.sql
-- Description: Creates database schema with sample data
-- ============================================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS emp_management;
USE emp_management;

-- -------------------------------------------------------
-- Table: departments
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS departments (
    dept_id     INT AUTO_INCREMENT PRIMARY KEY,
    dept_name   VARCHAR(100) NOT NULL,
    location    VARCHAR(100),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------
-- Table: employees
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS employees (
    emp_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    phone       VARCHAR(15),
    hire_date   DATE NOT NULL,
    job_title   VARCHAR(100),
    salary      DECIMAL(10,2),
    dept_id     INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

-- -------------------------------------------------------
-- Table: attendance
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id   INT AUTO_INCREMENT PRIMARY KEY,
    emp_id          INT NOT NULL,
    check_in        DATETIME,
    check_out       DATETIME,
    status          ENUM('Present', 'Absent', 'Leave') DEFAULT 'Present',
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: audit_log (tracks all DML changes)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    table_name  VARCHAR(100),
    action      VARCHAR(10),
    changed_by  VARCHAR(100),
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- -------------------------------------------------------
-- Insert Sample Data: Departments
-- -------------------------------------------------------
INSERT INTO departments (dept_name, location) VALUES
('Engineering',     'Mumbai'),
('Human Resources', 'Delhi'),
('Finance',         'Bangalore'),
('Marketing',       'Pune'),
('IT Support',      'Hyderabad');

-- -------------------------------------------------------
-- Insert Sample Data: Employees
-- -------------------------------------------------------
INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, salary, dept_id) VALUES
('Rahul',   'Sharma',   'rahul.sharma@company.com',   '9876543210', '2020-01-15', 'Software Engineer',   75000.00, 1),
('Priya',   'Patel',    'priya.patel@company.com',    '9876543211', '2019-06-20', 'HR Manager',          65000.00, 2),
('Amit',    'Verma',    'amit.verma@company.com',     '9876543212', '2021-03-10', 'Financial Analyst',   70000.00, 3),
('Sneha',   'Gupta',    'sneha.gupta@company.com',    '9876543213', '2022-07-01', 'Marketing Lead',      68000.00, 4),
('Vikram',  'Singh',    'vikram.singh@company.com',   '9876543214', '2018-11-05', 'IT Support Engineer', 55000.00, 5),
('Ananya',  'Reddy',    'ananya.reddy@company.com',   '9876543215', '2023-01-12', 'Junior Developer',    50000.00, 1),
('Karan',   'Mehta',    'karan.mehta@company.com',    '9876543216', '2020-09-18', 'Senior Developer',    90000.00, 1),
('Divya',   'Nair',     'divya.nair@company.com',     '9876543217', '2021-05-25', 'Recruiter',           48000.00, 2),
('Rohan',   'Joshi',    'rohan.joshi@company.com',    '9876543218', '2019-08-30', 'Finance Manager',     85000.00, 3),
('Meera',   'Pillai',   'meera.pillai@company.com',   '9876543219', '2022-02-14', 'SEO Specialist',      52000.00, 4);

-- -------------------------------------------------------
-- Insert Sample Data: Attendance
-- -------------------------------------------------------
INSERT INTO attendance (emp_id, check_in, check_out, status) VALUES
(1, '2024-06-01 09:00:00', '2024-06-01 18:00:00', 'Present'),
(2, '2024-06-01 09:15:00', '2024-06-01 17:45:00', 'Present'),
(3, '2024-06-01 09:30:00', '2024-06-01 18:30:00', 'Present'),
(4, NULL, NULL, 'Absent'),
(5, '2024-06-01 08:45:00', '2024-06-01 17:30:00', 'Present'),
(1, '2024-06-02 09:05:00', '2024-06-02 18:10:00', 'Present'),
(6, NULL, NULL, 'Leave'),
(7, '2024-06-02 09:00:00', '2024-06-02 18:00:00', 'Present');

-- -------------------------------------------------------
-- Trigger: Auto-log INSERT on employees table
-- -------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, changed_by, description)
    VALUES ('employees', 'INSERT', CURRENT_USER(), CONCAT('New employee added: ', NEW.first_name, ' ', NEW.last_name));
END$$
DELIMITER ;

SELECT 'Database setup complete!' AS Status;
