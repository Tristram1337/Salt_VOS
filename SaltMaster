#!/bin/bash

LOGFILE="/var/log/salt_masterA.log"
MASTER_SERVICE="salt-master"
SYNC_DIR="/srv/salt"
SLS_FILE="$SYNC_DIR/propagation_test.sls"
MASTER_ID=$(hostname)
INTERVAL=10
OFFSET=0
CHECK_INTERVAL=1

echo "$(date) | Starting Salt MasterA Monitor" | tee -a $LOGFILE

while true; do
    CURRENT_MINUTE=$(date +%M)
    CURRENT_MINUTE=$((10#$CURRENT_MINUTE))

    if (( (CURRENT_MINUTE - OFFSET) % INTERVAL == 0 )); then
        RANDOM_DELAY=$(( RANDOM % 31 ))
        echo "$(date) | Random delay of $RANDOM_DELAY seconds before stopping SaltMasterA" | tee -a $LOGFILE
        sleep $RANDOM_DELAY

        echo "$(date) | Stopping SaltMasterA ($MASTER_SERVICE)" | tee -a $LOGFILE
        systemctl stop $MASTER_SERVICE
        sleep 60

        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        cat <<EOF > "$SLS_FILE"
propagation_test:
  file.append:
    - name: /tmp/minion_propagation.log
    - text: "Propagation test file created at $TIMESTAMP on $MASTER_ID"
EOF
        echo "$(date) | Created Salt state file: $SLS_FILE with timestamp $TIMESTAMP" | tee -a $LOGFILE
        sleep 60

        echo "$(date) | Starting SaltMasterA ($MASTER_SERVICE)" | tee -a $LOGFILE
        systemctl start $MASTER_SERVICE
    fi

    sleep $CHECK_INTERVAL
done
