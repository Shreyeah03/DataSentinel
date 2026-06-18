#!/bin/bash
# ============================================================
# MySQL DBA Project
# File: backup.sh
# Description: Automated MySQL backup with retention policy
#              Supports full and individual database backups
# ============================================================

# ---------- CONFIGURATION ----------
DB_USER="backup_user"
DB_PASS="Backup@2024!"
DB_NAME="emp_management"
BACKUP_DIR="/var/backups/mysql"
LOG_FILE="/var/log/mysql_backup.log"
RETENTION_DAYS=7          # Keep backups for 7 days
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

# ---------- FUNCTIONS ----------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_dependencies() {
    for cmd in mysqldump gzip mysql; do
        if ! command -v "$cmd" &> /dev/null; then
            log "ERROR: '$cmd' not found. Please install it."
            exit 1
        fi
    done
}

create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

check_mysql_connection() {
    if ! mysql -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; then
        log "ERROR: Cannot connect to MySQL. Check credentials."
        exit 1
    fi
    log "MySQL connection verified ✅"
}

run_backup() {
    log "Starting backup of database: $DB_NAME"

    mysqldump \
        -u"$DB_USER" \
        -p"$DB_PASS" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --add-drop-table \
        --comments \
        "$DB_NAME" | gzip > "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        FILE_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
        log "Backup successful: $BACKUP_FILE (Size: $FILE_SIZE) ✅"
    else
        log "ERROR: Backup FAILED for $DB_NAME ❌"
        exit 1
    fi
}

delete_old_backups() {
    log "Removing backups older than $RETENTION_DAYS days..."
    DELETED=$(find "$BACKUP_DIR" -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -print -delete | wc -l)
    log "Deleted $DELETED old backup(s)"
}

show_backup_summary() {
    log "------- Backup Summary -------"
    log "Total backups stored:"
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tee -a "$LOG_FILE"
    log "Disk usage: $(du -sh $BACKUP_DIR)"
    log "------------------------------"
}

# ---------- MAIN ----------
log "========== MySQL Backup Started =========="
check_dependencies
create_backup_dir
check_mysql_connection
run_backup
delete_old_backups
show_backup_summary
log "========== MySQL Backup Completed =========="
