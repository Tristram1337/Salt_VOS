#!/bin/bash

LOGFILE="/var/log/salt_masterB.log"
MASTER_SERVICE="salt-master"
INTERVAL=10
OFFSET=5
CHECK_INTERVAL=1

echo "$(date) | Script started for SaltMasterB" | tee -a $LOGFILE

while true; do
    CURRENT_MINUTE=$(date +%M)
    CURRENT_MINUTE=$((10#$CURRENT_MINUTE))

    if (( (CURRENT_MINUTE - OFFSET) % INTERVAL == 0 )); then
        RANDOM_DELAY=$(( RANDOM % 31 ))
        echo "$(date) | Random delay of $RANDOM_DELAY seconds before stopping SaltMasterB" | tee -a $LOGFILE
        sleep $RANDOM_DELAY

        echo "$(date) | Stopping SaltMasterB ($MASTER_SERVICE)" | tee -a $LOGFILE
        systemctl stop $MASTER_SERVICE
        sleep 120

        echo "$(date) | Starting SaltMasterB ($MASTER_SERVICE)" | tee -a $LOGFILE
        systemctl start $MASTER_SERVICE
    fi

    sleep $CHECK_INTERVAL
done
