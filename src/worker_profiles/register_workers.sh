#!/bin/bash

CONFIG_FILE="worker_profiles/employer_worker_config.json"

# Check if JSON file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: employer_worker_config.json file not found!"
    exit 1
fi

# Extract employer and SubDAO info
EMPLOYER_NAME=$(jq -r '.employer_name' "$CONFIG_FILE")
EMPLOYER_ID=$(jq -r '.employer_id' "$CONFIG_FILE")
SUBDAO_ANS=$(jq -r '.subdao_ans' "$CONFIG_FILE")

echo "Registering workers for employer: $EMPLOYER_NAME ($EMPLOYER_ID) affiliated with SubDAO: $SUBDAO_ANS"

# Loop through workers and register them
jq -c '.workers[]' "$CONFIG_FILE" | while read worker; do
    WORKER_ANS=$(echo "$worker" | jq -r '.worker_ans')
    WORKER_ADDRESS=$(echo "$worker" | jq -r '.worker_address')
    ZPASS_ID=$(echo "$worker" | jq -r '.zpass_id')
    CATEGORY=$(echo "$worker" | jq -r '.category')
    
    echo "Registering Worker $WORKER_ANS ($WORKER_ADDRESS) with ZPass ID: $ZPASS_ID, category $CATEGORY under $SUBDAO_ANS..."
    
    # Execute Leo transition to register the worker with ANS name and ZPass ID
    leo run register_worker "$WORKER_ADDRESS" "$CATEGORY" "$SUBDAO_ANS" "$ZPASS_ID"
    
    if [ $? -eq 0 ]; then
        echo "✔ Worker $WORKER_ANS registered successfully!"
    else
        echo "❌ ERROR: Failed to register Worker $WORKER_ANS"
    fi
done
