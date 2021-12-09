#!/bin/bash

# set_replication sql-dumpfile
# Extracts the required information from the Change Master command and builds a new query from it.

MATTR=$(cat $1 | sed -n '/CHANGE MASTER TO/s/.*\(MASTER_LOG_FILE=.*,\) \(MASTER_LOG_POS=.*\)$/\1\n\2/p')

cat << 'EOF'
CHANGE MASTER TO 
    MASTER_HOST='localhost',
    MASTER_USER='replication',
    MASTER_PASSWORD='replication',
EOF
echo $MATTR

echo 'START SLAVE;'
echo 'SHOW SLAVE STATUS \G;'
