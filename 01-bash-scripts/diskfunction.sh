#!/bin/bash

# 1. Define the reusable function
check_disk() {
    echo "Running system disk health check..."
    
    # 2. Extract the root filesystem usage percentage as a raw number
    #    (df / -> grab line 2 -> grab column 5 -> strip the % sign)
    USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    # Define our warning threshold
    local threshold=80

    echo "Current Root Filesystem Usage: ${USAGE}%"

    # 3. Numeric conditional comparison
    if [ "$USAGE" -gt "$threshold" ]; then
        echo "🚨 CRITICAL WARNING: Disk usage is above ${threshold}%!"
    else
        echo "✅ All systems nominal. Disk space is well within safe limits."
    fi
}

# 4. Trigger/Call the function to run it
check_disk
