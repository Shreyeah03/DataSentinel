#!/bin/bash
# ============================================================
# MySQL DBA Project
# File: monitor.sh
# Description: Monitors MySQL server health, performance,
#              connections, and disk usage
# ============================================================

# ---------- CONFIGURATION ----------
DB_USER="root"
DB_NAME="emp_management"
LOG_FILE="/var/log/mysql_monitor.log"
ALERT_CONNECTIONS=80      # Alert if connections > 80%
ALERT_DISK_USAGE=85       # Alert if disk usage > 85%

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---------- FUNCTIONS ----------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_section() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

check_mysql_status() {
    print_section "MySQL Service Status"
    if systemctl is-active --quiet mysql; then
        echo -e "${GREEN}  ✅ MySQL is RUNNING${NC}"
        log "MySQL service: RUNNING"
    else
        echo -e "${RED}  ❌ MySQL is NOT running!${NC}"
        log "ALERT: MySQL service is DOWN"
    fi
}

check_connections() {
    print_section "Active Connections"
    CURRENT=$(mysql -u"$DB_USER" -p -se "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | awk '{print $2}')
    MAX=$(mysql -u"$DB_USER" -p -se "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | awk '{print $2}')

    if [ -n "$CURRENT" ] && [ -n "$MAX" ]; then
        USAGE=$(( CURRENT * 100 / MAX ))
        echo "  Current Connections : $CURRENT"
        echo "  Max Connections     : $MAX"
        echo "  Usage               : $USAGE%"

        if [ "$USAGE" -gt "$ALERT_CONNECTIONS" ]; then
            echo -e "${RED}  ⚠️  WARNING: High connection usage!${NC}"
            log "ALERT: Connection usage at $USAGE%"
        else
            echo -e "${GREEN}  ✅ Connection usage is normal${NC}"
        fi
    else
        echo "  Could not fetch connection stats"
    fi
}

check_slow_queries() {
    print_section "Slow Query Stats"
    SLOW=$(mysql -u"$DB_USER" -p -se "SHOW STATUS LIKE 'Slow_queries';" 2>/dev/null | awk '{print $2}')
    echo "  Slow Queries Since Start: ${SLOW:-N/A}"

    if [ -n "$SLOW" ] && [ "$SLOW" -gt 0 ]; then
        echo -e "${YELLOW}  ⚠️  Consider enabling slow query log for analysis${NC}"
        log "NOTICE: $SLOW slow queries detected"
    fi
}

check_uptime() {
    print_section "MySQL Server Uptime"
    UPTIME=$(mysql -u"$DB_USER" -p -se "SHOW STATUS LIKE 'Uptime';" 2>/dev/null | awk '{print $2}')
    if [ -n "$UPTIME" ]; then
        DAYS=$(( UPTIME / 86400 ))
        HOURS=$(( (UPTIME % 86400) / 3600 ))
        MINS=$(( (UPTIME % 3600) / 60 ))
        echo "  Server Uptime: ${DAYS}d ${HOURS}h ${MINS}m"
        log "Server uptime: ${DAYS}d ${HOURS}h ${MINS}m"
    fi
}

check_disk_usage() {
    print_section "Disk Usage (MySQL Data Directory)"
    DATA_DIR=$(mysql -u"$DB_USER" -p -se "SHOW VARIABLES LIKE 'datadir';" 2>/dev/null | awk '{print $2}')
    DATA_DIR="${DATA_DIR:-/var/lib/mysql}"

    USAGE=$(df -h "$DATA_DIR" 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%')
    DISK_INFO=$(df -h "$DATA_DIR" 2>/dev/null | awk 'NR==2{print "Used: "$3" / Total: "$2" | Free: "$4}')

    echo "  Data Directory: $DATA_DIR"
    echo "  $DISK_INFO"
    echo "  Usage: $USAGE%"

    if [ -n "$USAGE" ] && [ "$USAGE" -gt "$ALERT_DISK_USAGE" ]; then
        echo -e "${RED}  ⚠️  WARNING: Disk usage is HIGH!${NC}"
        log "ALERT: Disk usage at $USAGE%"
    else
        echo -e "${GREEN}  ✅ Disk usage is normal${NC}"
    fi
}

check_table_sizes() {
    print_section "Top 5 Largest Tables in $DB_NAME"
    mysql -u"$DB_USER" -p -e "
        SELECT
            table_name AS 'Table',
            ROUND((data_length + index_length) / 1024, 2) AS 'Size (KB)',
            table_rows AS 'Approx Rows'
        FROM information_schema.tables
        WHERE table_schema = '$DB_NAME'
        ORDER BY (data_length + index_length) DESC
        LIMIT 5;
    " 2>/dev/null
}

# ---------- MAIN ----------
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     MySQL Health Monitoring Report       ║${NC}"
echo -e "${BLUE}║     $(date '+%Y-%m-%d %H:%M:%S')              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"

log "========== Monitoring Check Started =========="
check_mysql_status
check_connections
check_slow_queries
check_uptime
check_disk_usage
check_table_sizes
log "========== Monitoring Check Completed =========="

echo ""
echo -e "${GREEN}  Report logged to: $LOG_FILE${NC}"
echo ""
