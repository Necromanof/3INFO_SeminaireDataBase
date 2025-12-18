#!/bin/bash

# Config
DB_NAME="technofix"
DB_USER="test"
DB_HOST="pg"
DB_PORT="5432"
BACKUP_DIR="/logs"
MAX_RETRIES=3
RETRY_DELAY=10
KEEP_DAYS=14  # Keep last 14 days of backups

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_full_backup_$TIMESTAMP.sql.gz"

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

backup() {
    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        log "Starting full backup attempt $attempt..."
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

        if [ $? -eq 0 ]; then
            log "Full backup successful! File saved to $BACKUP_FILE"
            cleanup
            return 0
        else
            log "Full backup failed on attempt $attempt."
            attempt=$((attempt+1))
            if [ $attempt -le $MAX_RETRIES ]; then
                log "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            else
                log "Max retries reached. Full backup failed."
                return 1
            fi
        fi
    done
}

cleanup() {
    log "Cleaning up old backups older than $KEEP_DAYS days..."
    find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$KEEP_DAYS -exec rm -f {} \;
}

backup
