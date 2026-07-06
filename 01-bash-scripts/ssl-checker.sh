#!/bin/bash
set -euo pipefail
DOMAINS=("google.com" "github.com")   # replace with your domains
WARN_DAYS=30
for domain in "${DOMAINS[@]}"; do
    expiry=$(echo | timeout 5 openssl s_client -connect "${domain}:443" \
             -servername "$domain" 2>/dev/null \
             | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2) || {
        echo "WARN: $domain unreachable"; continue; }
    days=$(( ( $(date -d "$expiry" +%s) - $(date +%s) ) / 86400 ))
    [[ $days -le $WARN_DAYS ]] \
        && echo "WARN:  $domain expires in ${days} days ($expiry)" \
        || echo "OK:    $domain expires in ${days} days"
done
