#!/bin/bash
DISK=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
if [[ $DISK -ge 90 ]]; then
	echo "CRITICAL: Disk at ${DISK}%"
elif [[ $DISK -ge 80 ]]; then
	echo "WARNING: Disk at ${DISK}%"
else
	echo "OK: Disk at ${DISK}%"
fi
