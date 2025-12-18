#!/bin/bash
echo "Starting cron..."
chmod +x /scripts/*.sh 2>/dev/null
crond -f -l 2
