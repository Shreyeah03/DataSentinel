#!/bin/bash
# ============================================================
# MySQL DBA Project
# File: install_mysql.sh
# Description: Installs and configures MySQL on Ubuntu/Debian
# ============================================================

set -e  # Exit on any error

echo "========================================"
echo "  MySQL Installation & Setup Script"
echo "========================================"

# ----- Step 1: Update system packages -----
echo "[1/6] Updating package list..."
sudo apt-get update -y

# ----- Step 2: Install MySQL Server -----
echo "[2/6] Installing MySQL Server..."
sudo apt-get install -y mysql-server

# ----- Step 3: Start and enable MySQL -----
echo "[3/6] Starting MySQL service..."
sudo systemctl start mysql
sudo systemctl enable mysql

# ----- Step 4: Verify MySQL is running -----
echo "[4/6] Verifying MySQL service..."
if systemctl is-active --quiet mysql; then
    echo "  ✅ MySQL is running"
else
    echo "  ❌ MySQL failed to start. Check: sudo journalctl -xe"
    exit 1
fi

# ----- Step 5: Print MySQL version -----
echo "[5/6] MySQL version:"
mysql --version

# ----- Step 6: Reminder to secure MySQL -----
echo "[6/6] IMPORTANT: Run the following to secure your MySQL installation:"
echo "      sudo mysql_secure_installation"
echo ""
echo "========================================"
echo "  MySQL Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Run: sudo mysql_secure_installation"
echo "  2. Run: mysql -u root -p < setup/create_database.sql"
echo "  3. Run: mysql -u root -p < setup/create_users.sql"
