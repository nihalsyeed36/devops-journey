#!/bin/bash
#author:syy1cob
# 1. Define the list of domains
DOMAINS="google.com github.com fake-website-xyz.org"

echo "Starting Website Status Check..."
echo "--------------------------------"

# 2. Loop through each domain
for SITE in $DOMAINS; do
    
    # 3. Use curl to check the site header. 
    # --connect-timeout 2 stops it from freezing if the site is totally dead.
    curl -I -s --connect-timeout 2 "$SITE" > /dev/null 2>&1
    
    # 4. Check the exit status ($?) of the curl command
    if [ $? -eq 0 ]; then
        echo "🟢 $SITE is UP"
    else
        echo "🔴 $SITE is DOWN!"
    fi
done

echo "--------------------------------"
echo "Status check complete."
