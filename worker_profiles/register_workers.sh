#!/bin/bash

# Check if workers.json exists
if [ ! -f "workers.json" ]; then
    echo "ERROR: workers.json file not found!"
    exit 1
fi

# Extract DAO ID from JSON
DAO_ID=$(jq -r '.dao_id' workers.json)

# Loop through workers and register them
jq -c '.workers[]' workers.json | while read worker; do
    WORKER_ADDRESS=$(echo "$worker" | jq -r '.address')
    CATEGORY=$(echo "$worker" | jq -r '.category')
    
    echo "Registering worker $WORKER_ADDRESS with category $CATEGORY in DAO $DAO_ID..."
    
    # Run the Leo transition to register the worker
    leo run register_worker "$WORKER_ADDRESS" "$CATEGORY" "$DAO_ID"
    
    if [ $? -eq 0 ]; then
        echo "✔ Worker $WORKER_ADDRESS registered successfully!"
    else
        echo "❌ ERROR: Failed to register $WORKER_ADDRESS"
    fi
done
