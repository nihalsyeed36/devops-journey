#!/bin/bash
# ============================================================
# system-health-report.sh
# Monitors: disk, memory, CPU, services, SSL certificates
# Usage:  ./system-health-report.sh [--email ops@company.com]
# Cron:   */30 * * * * /opt/scripts/health-report.sh
# GitHub: 01-bash-scripts/health-report.sh
# ============================================================
set -euo pipefail
IFS=$'\\n\\t'
 
# ── CONFIGURATION ─────────────────────────────────────────
HOSTNAME=$(hostname -f)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="/tmp/health-$(date '+%Y%m%d-%H%M').txt"
DISK_WARN=80;   DISK_CRIT=90
MEM_WARN=85;    MEM_CRIT=95
CPU_WARN=70;    CPU_CRIT=90
SERVICES=("dbus" "cron")   # add your services here
SSL_DOMAINS=("google.com")                   # add domains: ("app.example.com")
OVERALL_STATUS=0                 # 0=OK 1=WARN 2=CRIT
 
# ── OUTPUT HELPERS ─────────────────────────────────────────
OK()   { echo "  [  OK  ] $*"; }
WARN() { echo "  [ WARN ] $*"; [[ $OVERALL_STATUS -lt 1 ]] && OVERALL_STATUS=1; }
CRIT() { echo "  [ CRIT ] $*"; OVERALL_STATUS=2; }
HDR()  { echo; echo "┌─────────────────────────────────────────────┐";
         printf  "│  %-43s│\\n" "$*";
         echo    "└─────────────────────────────────────────────┘"; }
 
# ── DISK CHECK ─────────────────────────────────────────────
check_disk() {
    HDR "DISK USAGE"
while IFS= read -r line; do
        local fs mp pct
        fs=$(awk '{print $1}' <<< "$line")
        mp=$(awk '{print $6}' <<< "$line")
        pct=$(awk '{print $5}' <<< "$line" | tr -d '%')
        [[ "$pct" =~ ^[0-9]+$ ]] || continue
        if   [[ $pct -ge $DISK_CRIT ]]; then CRIT "$mp at ${pct}% — CRITICAL ($fs)"
        elif [[ $pct -ge $DISK_WARN ]]; then WARN "$mp at ${pct}% — WARNING ($fs)"
        else OK "$mp at ${pct}% ($fs)"
        fi
    done < <(df -hP | tail -n +2)
}
 
# ── MEMORY CHECK ────────────────────────────────────────────
check_memory() {
    HDR "MEMORY"
    local total used free pct
    read -r total used free < <(free -m | awk '/^Mem/{print $2,$3,$4}')
    pct=$(( used * 100 / total ))
    if   [[ $pct -ge $MEM_CRIT ]]; then CRIT "Memory ${pct}% — ${used}MB/${total}MB"
    elif [[ $pct -ge $MEM_WARN ]]; then WARN "Memory ${pct}% — ${used}MB/${total}MB"
    else OK "Memory ${pct}% used (${used}MB / ${total}MB total)"
    fi
    local swap_total swap_used
    read -r swap_total swap_used < <(free -m | awk '/^Swap/{print $2,$3}')
    if [[ $swap_total -gt 0 ]]; then
        local swap_pct=$(( swap_used * 100 / swap_total ))
        [[ $swap_pct -gt 50 ]] && WARN "Swap ${swap_pct}% used — ${swap_used}MB/${swap_total}MB" \
                                || OK "Swap ${swap_pct}% used"
    fi
}
 
# ── CPU CHECK ────────────────────────────────────────────────
check_cpu() {
    HDR "CPU LOAD"
    local cpus load1 load5 load15
    cpus=$(nproc)
    read -r load1 load5 load15 _ < /proc/loadavg
    local pct=$(awk "BEGIN{printf \"%d\", $load1/$cpus*100}")
    if   [[ $pct -ge $CPU_CRIT ]]; then CRIT "Load ${load1} = ${pct}% of ${cpus} CPUs"
    elif [[ $pct -ge $CPU_WARN ]]; then WARN "Load ${load1} = ${pct}% of ${cpus} CPUs"
    else OK "Load: 1min=${load1} 5min=${load5} 15min=${load15} (${cpus} CPUs)"
    fi
    # Top 3 CPU consumers
    echo "  Top CPU processes:"
    ps aux --sort=-%cpu | awk 'NR>1 && NR<=4 {printf "    %5s%%  %s\\n", $3, $11}'
}
 
# ── SERVICE CHECK ────────────────────────────────────────────
check_services() {
    HDR "SERVICES"
    for svc in "${SERVICES[@]}"; do
	if systemctl is-active --quiet "$svc" 2>/dev/null; then
            local pid uptime
            pid=$(systemctl show "$svc" --property=MainPID --value 2>/dev/null)
            OK "$svc (PID: $pid)"
        else
            CRIT "$svc is NOT running"
            echo "  Last log lines:"
            journalctl -u "$svc" -n 5 --no-pager 2>/dev/null | sed 's/^/    /'
        fi
    done
}
 
# ── SSL CHECK ────────────────────────────────────────────────
check_ssl() {
    [[ ${#SSL_DOMAINS[@]} -eq 0 ]] && return
    HDR "SSL CERTIFICATES"
    for domain in "${SSL_DOMAINS[@]}"; do
        local expiry days
        expiry=$(echo | timeout 5 openssl s_client -connect "${domain}:443" \
                 -servername "$domain" 2>/dev/null \
                 | openssl x509 -noout -enddate 2>/dev/null \
                 | cut -d= -f2) || { WARN "$domain — connection failed"; continue; }
        days=$(( ( $(date -d "$expiry" +%s) - $(date +%s) ) / 86400 ))
        if   [[ $days -le 7  ]]; then CRIT "$domain — EXPIRES IN ${days} DAYS! ($expiry)"
        elif [[ $days -le 30 ]]; then WARN "$domain — expires in ${days} days"
        else OK "$domain — ${days} days remaining"
        fi
    done
}
 
# ── MAIN ────────────────────────────────────────────────────
main() {
    {
        echo "╔══════════════════════════════════════════════╗"
        printf "║  %-44s║\\n" "SYSTEM HEALTH REPORT"
        printf "║  %-44s║\\n" "Host: $HOSTNAME"
        printf "║  %-44s║\\n" "Date: $TIMESTAMP"
        echo "╚══════════════════════════════════════════════╝"
        check_disk
        check_memory
        check_cpu
        check_services
        check_ssl
        echo
        local status_text
        case $OVERALL_STATUS in
            0) status_text="ALL SYSTEMS OK" ;;
            1) status_text="WARNINGS DETECTED" ;;
            2) status_text="CRITICAL ISSUES DETECTED" ;;
        esac
        echo "  OVERALL STATUS: $status_text (code: $OVERALL_STATUS)"
        echo "  Report saved: $REPORT_FILE"
    } | tee "$REPORT_FILE"
 
    # Email if --email flag provided
    if [[ "${1:-}" == "--email" && -n "${2:-}" ]]; then
	        mail -s "[$(hostname -s)] Health: $status_text" "$2" < "$REPORT_FILE"
    fi
    exit $OVERALL_STATUS
}
main "$@"



