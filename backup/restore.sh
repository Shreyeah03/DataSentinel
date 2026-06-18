#!/bin/bash
# ============================================================
# MySQL DBA Project
# File: restore.sh
# Description: Restores MySQL database from a .sql.gz backup
# Usage: ./restore.sh /path/to/backup_file.sql.gz
# ============================================================

# ---------- CONFIGURATION ----------
DB_USER="root"
DB_NAME="emp_management"
LOG_FILE="/var/log/mysql_restore.log"

# ---------- FUNCTIONS ----------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <backup_file.sql.gz>"
    echo "Example: $0 /var/backups/mysql/emp_management_2024-06-01_10-00-00.sql.gz"
    exit 1
}

validate_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log "ERROR: File not found: $file"
        exit 1
    fi
    if [[ "$file" != *.sql.gz ]]; then
        log "ERROR: File must be a .sql.gz archive"
        exit 1
    fi
    log "Backup file validated: $file ✅"
}

confirm_restore() {
    echo ""
    echo "⚠️  WARNING: This will DROP and RECREATE the database: $DB_NAME"
    echo "   All existing data will be LOST!"
    echo ""
    read -rp "Are you sure you want to restore? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log "Restore cancelled by user."
        exit 0
    fi
}

restore_database() {
    local backup_file="$1"

    log "Restoring database: $DB_NAME from $backup_file"

    # Drop and recreate the database
    mysql -u"$DB_USER" -p -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"

    if [ $? -ne 0 ]; then
        log "ERROR: Failed to recreate database ❌"
        exit 1
    fi

    # Decompress and restore
    gunzip -c "$backup_file" | mysql -u"$DB_USER" -p "$DB_NAME"

    if [ $? -eq 0 ]; then
        log "Database restored successfully ✅"
    else
        log "ERROR: Restore FAILED ❌"
        exit 1
    fi
}

verify_restore() {
    log "Verifying restore..."
    TABLE_COUNT=$(mysql -u"$DB_USER" -p -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>/dev/null)
    log "Tables restored: $TABLE_COUNT"
    log "Restore verification complete ✅"
}

# ---------- MAIN ----------
[ -z "$1" ] && usage

BACKUP_FILE="$1"

log "========== MySQL Restore Started =========="
validate_file "$BACKUP_FILE"
confirm_restore
restore_database "$BACKUP_FILE"
verify_restore
log "========== MySQL Restore Completed =========="
