#!/bin/bash
export PGPASSWORD=password

psql -h postgres -U user -d mydb \
  -c "VACUUM (VERBOSE, ANALYZE);"

echo "Vacuum done at $(date)"