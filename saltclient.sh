LOGFILE="/var/log/salt_minion_monitor.log"
CHECK_INTERVAL=1
MASTER_PORT=4506
PROPAGATION_LOG="/tmp/minion_propagation.log"

SCRIPT_START_TIME=$(date +%s)

echo "$(date) | Monitoring Salt Minion connection and file propagation every $CHECK_INTERVAL seconds" | tee -a $LOGFILE

function print_summary {
    if (( outage_count > 0 )); then
        avg_outage_duration=$(( total_outage_duration / outage_count ))
    else
        avg_outage_duration=0
    fi

    echo "-------------------------------------------" | tee -a $LOGFILE
    echo "Total outages: $outage_count" | tee -a $LOGFILE
    echo "Total downtime: ${total_outage_duration}s" | tee -a $LOGFILE
    echo "Average outage duration: ${avg_outage_duration}s" | tee -a $LOGFILE
    echo "Longest outage: ${longest_outage}s" | tee -a $LOGFILE

    if (( shortest_outage > 0 )); then
        echo "Shortest outage: ${shortest_outage}s" | tee -a $LOGFILE
    else
        echo "Shortest outage: N/A (No outages detected)" | tee -a $LOGFILE
    fi

    echo "-------------------------------------------" | tee -a $LOGFILE
}

trap print_summary EXIT

last_known_timestamp=""
last_logged_entry=""
last_master=""
logged_connection=false
outage_detected=false

outage_count=0
total_outage_duration=0
longest_outage=0
shortest_outage=-1

while true; do
    current_master=$(ss -tnp | grep ":$MASTER_PORT" | awk '{print $5}' | cut -d: -f1 | xargs -I{} getent hosts {} | awk '{print $2}' | sort -u | head -n1)

    if [[ -n "$current_master" ]]; then
        if $outage_detected; then
            outage_end=$(date +%s)
            outage_duration=$(( outage_end - outage_start ))
            total_outage_duration=$(( total_outage_duration + outage_duration ))
            outage_count=$(( outage_count + 1 ))

            if (( outage_duration > longest_outage )); then
                longest_outage=$outage_duration
            fi
            if (( shortest_outage == -1 || outage_duration < shortest_outage )); then
                shortest_outage=$outage_duration
            fi

            echo "$(date) | Connection restored after $outage_duration seconds | Connected to: $current_master" | tee -a $LOGFILE
            outage_detected=false
            logged_connection=false
        fi

        if [[ "$current_master" != "$last_master" ]]; then
            echo "$(date) | Now connected to: $current_master" | tee -a $LOGFILE
            last_master="$current_master"
            logged_connection=true
        fi
    else
        if ! $outage_detected; then
            outage_start=$(date +%s)
            echo "$(date) | Connection lost" | tee -a $LOGFILE
            outage_detected=true
            logged_connection=false
        fi
    fi

    if [[ -f "$PROPAGATION_LOG" ]]; then
        NEW_TIMESTAMP=$(tail -1 "$PROPAGATION_LOG" | grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')
        if [[ -z "$NEW_TIMESTAMP" || "$NEW_TIMESTAMP" == "$last_logged_entry" ]]; then
            sleep $CHECK_INTERVAL
            continue
        fi
        last_logged_entry="$NEW_TIMESTAMP"
        FILE_EPOCH=$(date -d "$NEW_TIMESTAMP" +%s 2>/dev/null)
        if [[ ! "$FILE_EPOCH" =~ ^[0-9]+$ ]]; then
            sleep $CHECK_INTERVAL
            continue
        fi
        if (( FILE_EPOCH < SCRIPT_START_TIME )); then
            sleep $CHECK_INTERVAL
            continue
        fi
        if [[ "$NEW_TIMESTAMP" != "$last_known_timestamp" ]]; then
            CURRENT_EPOCH=$(date +%s)
            PROPAGATION_TIME=$(( CURRENT_EPOCH - FILE_EPOCH ))
            echo "$(date) | Propagation time from MasterA: ${PROPAGATION_TIME}s" | tee -a $LOGFILE
            last_known_timestamp="$NEW_TIMESTAMP"
        fi
    fi

    sleep $CHECK_INTERVAL
done                                         
