-- ============================================================
-- MySQL DBA Project
-- File: user_permissions.sql
-- Description: Security audit, permission review, and
--              hardening queries for MySQL DBA
-- ============================================================

-- -------------------------------------------------------
-- 1. AUDIT: VIEW ALL MYSQL USERS
-- -------------------------------------------------------
SELECT 'Auditing all MySQL users...' AS Info;

SELECT
    User,
    Host,
    account_locked,
    password_expired,
    password_last_changed
FROM mysql.user
ORDER BY User;

-- -------------------------------------------------------
-- 2. AUDIT: VIEW ALL USER PRIVILEGES
-- -------------------------------------------------------
SELECT 'Checking user privileges...' AS Info;

-- Show grants for each project user
SHOW GRANTS FOR 'app_user'@'localhost';
SHOW GRANTS FOR 'read_only_user'@'localhost';
SHOW GRANTS FOR 'hr_user'@'localhost';
SHOW GRANTS FOR 'backup_user'@'localhost';

-- -------------------------------------------------------
-- 3. CHECK: Users with Global Privileges (security risk)
-- -------------------------------------------------------
SELECT
    User,
    Host,
    Super_priv,
    Grant_priv,
    Shutdown_priv
FROM mysql.user
WHERE Super_priv = 'Y' OR Grant_priv = 'Y';

-- -------------------------------------------------------
-- 4. CHECK: Users with no password (security risk)
-- -------------------------------------------------------
SELECT
    User,
    Host,
    authentication_string
FROM mysql.user
WHERE authentication_string = ''
   OR authentication_string IS NULL;

-- -------------------------------------------------------
-- 5. REVOKE dangerous privilege example
--    (Uncomment to execute if needed)
-- -------------------------------------------------------
-- REVOKE SUPER ON *.* FROM 'some_user'@'localhost';
-- FLUSH PRIVILEGES;

-- -------------------------------------------------------
-- 6. LOCK an inactive account
-- -------------------------------------------------------
-- ALTER USER 'inactive_user'@'localhost' ACCOUNT LOCK;

-- -------------------------------------------------------
-- 7. PASSWORD POLICY: Expire old password
-- -------------------------------------------------------
-- ALTER USER 'app_user'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;

-- -------------------------------------------------------
-- 8. VIEW: Active connections right now
-- -------------------------------------------------------
SELECT 'Active connections:' AS Info;

SELECT
    id,
    user,
    host,
    db,
    command,
    time,
    state
FROM information_schema.processlist
WHERE command != 'Sleep'
ORDER BY time DESC;

-- -------------------------------------------------------
-- 9. KILL a long-running query (example)
--    Replace <process_id> with actual ID from above query
-- -------------------------------------------------------
-- KILL QUERY <process_id>;

SELECT 'Security audit complete!' AS Status;
