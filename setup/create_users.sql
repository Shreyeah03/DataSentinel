-- ============================================================
-- MySQL DBA Project
-- File: create_users.sql
-- Description: Creates roles, users, and grants permissions
-- This demonstrates real-world DBA access control
-- ============================================================

USE emp_management;

-- -------------------------------------------------------
-- Drop existing users if they exist (safe re-run)
-- -------------------------------------------------------
DROP USER IF EXISTS 'app_user'@'localhost';
DROP USER IF EXISTS 'read_only_user'@'localhost';
DROP USER IF EXISTS 'hr_user'@'localhost';
DROP USER IF EXISTS 'backup_user'@'localhost';

-- -------------------------------------------------------
-- 1. APPLICATION USER
--    Used by the backend app to read/write data
-- -------------------------------------------------------
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'AppUser@2024!';

-- Grant SELECT, INSERT, UPDATE, DELETE on all tables
GRANT SELECT, INSERT, UPDATE, DELETE
    ON emp_management.*
    TO 'app_user'@'localhost';

-- -------------------------------------------------------
-- 2. READ-ONLY USER
--    Used for reporting and analytics (no modifications)
-- -------------------------------------------------------
CREATE USER 'read_only_user'@'localhost' IDENTIFIED BY 'ReadOnly@2024!';

GRANT SELECT
    ON emp_management.*
    TO 'read_only_user'@'localhost';

-- -------------------------------------------------------
-- 3. HR USER
--    Can only access employees and attendance tables
-- -------------------------------------------------------
CREATE USER 'hr_user'@'localhost' IDENTIFIED BY 'HRUser@2024!';

GRANT SELECT, INSERT, UPDATE
    ON emp_management.employees
    TO 'hr_user'@'localhost';

GRANT SELECT, INSERT, UPDATE
    ON emp_management.attendance
    TO 'hr_user'@'localhost';

-- -------------------------------------------------------
-- 4. BACKUP USER
--    Minimal permissions required to run mysqldump
-- -------------------------------------------------------
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'Backup@2024!';

GRANT SELECT, SHOW VIEW, RELOAD, LOCK TABLES, EVENT, TRIGGER
    ON *.*
    TO 'backup_user'@'localhost';

-- -------------------------------------------------------
-- Apply all privilege changes
-- -------------------------------------------------------
FLUSH PRIVILEGES;

-- -------------------------------------------------------
-- Verify: Show all users and their hosts
-- -------------------------------------------------------
SELECT User, Host, account_locked
FROM mysql.user
WHERE User IN ('app_user', 'read_only_user', 'hr_user', 'backup_user');

SELECT 'Users created successfully!' AS Status;
