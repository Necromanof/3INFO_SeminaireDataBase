#!/bin/bash

# Config
DB_NAME="technofix"
DB_USER="test"
DB_HOST="pg"
DB_PORT="5432"
BACKUP_DIR="/logs"
MAX_RETRIES=3
RETRY_DELAY=10
KEEP_HOURS=72  # Keep last 72h (3 days)

TABLES="LU_Customer LU_Site_Address F_Intervention F_Notation F_Skill"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_partial_backup_$TIMESTAMP.sql.gz"

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

backup() {
    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        log "Starting partial backup attempt $attempt..."
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -t "$TABLES" "$DB_NAME" | gzip > "$BACKUP_FILE"

        if [ $? -eq 0 ]; then
            log "Partial backup successful! File saved to $BACKUP_FILE"
            cleanup
            return 0
        else
            log "Partial backup failed on attempt $attempt."
            attempt=$((attempt+1))
            if [ $attempt -le $MAX_RETRIES ]; then
                log "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            else
                log "Max retries reached. Partial backup failed."
                return 1
            fi
        fi
    done
}

cleanup() {
    log "Cleaning up partial backups older than $KEEP_HOURS hours..."
    find "$BACKUP_DIR" -type f -name "*.sql.gz" -mmin +$((KEEP_HOURS*60)) -exec rm -f {} \;
}

backup
