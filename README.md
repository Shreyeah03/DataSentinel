# 🗄️ MySQL DBA Project — Employee Management System

A complete **Database Administration** project built to demonstrate real-world MySQL DBA skills including database design, user access control, automated backups, performance monitoring, and security auditing.

---

## 📋 Project Overview

This project simulates a production-grade **Employee Management System** managed end-to-end by a DBA. It covers all key responsibilities of a MySQL Database Administrator.

---

## 🧰 Skills Demonstrated

| Skill | Files |
|-------|-------|
| MySQL Installation & Setup | `setup/install_mysql.sh` |
| Database Design & Schema | `setup/create_database.sql` |
| User Access Control | `setup/create_users.sql`, `security/user_permissions.sql` |
| Backup & Recovery | `backup/backup.sh`, `backup/restore.sh` |
| Performance Monitoring | `monitoring/monitor.sh`, `monitoring/performance_check.sql` |
| Linux Shell Scripting | All `.sh` files |
| Indexing & Query Optimization | `monitoring/performance_check.sql` |
| Security Auditing | `security/user_permissions.sql` |

---

## 📁 Project Structure

```
mysql-dba-project/
│
├── setup/
│   ├── install_mysql.sh          # Installs MySQL on Ubuntu/Debian
│   ├── create_database.sql       # Creates DB, tables, sample data, triggers
│   └── create_users.sql          # Creates users with role-based permissions
│
├── backup/
│   ├── backup.sh                 # Automated backup with compression & retention
│   └── restore.sh                # Safely restores from a .sql.gz backup file
│
├── monitoring/
│   ├── monitor.sh                # MySQL health check (connections, disk, uptime)
│   └── performance_check.sql     # Indexing, EXPLAIN, query optimization
│
├── security/
│   └── user_permissions.sql      # Security audit, privilege review, hardening
│
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Ubuntu 20.04+ or Debian-based Linux
- MySQL 8.0+
- Bash shell

---

### Step 1: Install MySQL

```bash
chmod +x setup/install_mysql.sh
./setup/install_mysql.sh
```

Then secure your installation:
```bash
sudo mysql_secure_installation
```

---

### Step 2: Create the Database

```bash
mysql -u root -p < setup/create_database.sql
```

This creates:
- `emp_management` database
- `departments`, `employees`, `attendance`, `audit_log` tables
- Sample data (10 employees, 5 departments)
- Trigger for automatic audit logging

---

### Step 3: Create Users & Permissions

```bash
mysql -u root -p < setup/create_users.sql
```

Creates 4 users with different access levels:

| User | Role | Permissions |
|------|------|-------------|
| `app_user` | Application | SELECT, INSERT, UPDATE, DELETE |
| `read_only_user` | Reporting | SELECT only |
| `hr_user` | HR Team | Access to employees & attendance only |
| `backup_user` | DBA Backup | Minimal backup permissions |

---

### Step 4: Run Backup

```bash
chmod +x backup/backup.sh
./backup/backup.sh
```

- Creates a compressed `.sql.gz` backup
- Automatically deletes backups older than 7 days
- Logs all activity to `/var/log/mysql_backup.log`

**To schedule daily backups using cron:**
```bash
crontab -e
# Add this line to run backup every day at 2 AM:
0 2 * * * /path/to/mysql-dba-project/backup/backup.sh
```

---

### Step 5: Restore from Backup

```bash
chmod +x backup/restore.sh
./backup/restore.sh /var/backups/mysql/emp_management_2024-06-01_02-00-00.sql.gz
```

---

### Step 6: Monitor MySQL Health

```bash
chmod +x monitoring/monitor.sh
./monitoring/monitor.sh
```

Checks:
- MySQL service status
- Active connections vs max connections
- Slow queries count
- Server uptime
- Disk usage with alerts
- Top 5 largest tables

---

### Step 7: Performance Tuning

```bash
mysql -u root -p < monitoring/performance_check.sql
```

Includes:
- Index creation on key columns
- `EXPLAIN` analysis of JOIN queries
- Table optimization
- Business analytics queries

---

### Step 8: Security Audit

```bash
mysql -u root -p < security/user_permissions.sql
```

Reviews:
- All MySQL users and their host access
- Users with dangerous global privileges
- Accounts with no password (security risk)
- Active connections and long-running processes

---

## 📊 Database Schema

```
departments
  └── dept_id (PK)
  └── dept_name
  └── location

employees
  └── emp_id (PK)
  └── first_name, last_name, email
  └── salary, job_title, hire_date
  └── dept_id (FK → departments)

attendance
  └── attendance_id (PK)
  └── emp_id (FK → employees)
  └── check_in, check_out, status

audit_log
  └── log_id (PK)
  └── table_name, action, changed_by, changed_at
```

---

## 🔐 Security Notes

- All passwords should be changed before use in production
- Use environment variables or a secrets manager for passwords in scripts
- Regularly rotate user passwords
- Run `security/user_permissions.sql` periodically for auditing

---

## 🛠️ Tech Stack

- **Database**: MySQL 8.0
- **OS**: Ubuntu/Debian Linux
- **Scripting**: Bash Shell
- **Backup**: mysqldump + gzip
- **Scheduling**: cron

---

## 👨‍💻 Author

**Your Name**  
MySQL DBA | Linux Administration | Shell Scripting  
📧 your.email@example.com  
🔗 [LinkedIn](https://linkedin.com/in/yourprofile) | [GitHub](https://github.com/yourusername)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
# DataSentinel
