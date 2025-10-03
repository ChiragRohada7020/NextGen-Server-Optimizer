#!/bin/bash
# utils for NextGen v4

LOG_FILE="/var/log/nextgen-optimizer.log"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

# ensure log file exists
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

run() {
  local cmd="$*"
  printf "${YELLOW}[>]${NC} %s\n" "$cmd"
  echo "[$(date '+%F %T')] CMD: $cmd" >> "$LOG_FILE"
  bash -c "$cmd" >> "$LOG_FILE" 2>&1
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    printf "${GREEN}[OK]${NC} %s\n" "$cmd"
    echo "[$(date '+%F %T')] OK: $cmd" >> "$LOG_FILE"
  else
    printf "${RED}[FAIL]${NC} %s (rc=%d)\n" "$cmd" "$rc"
    echo "[$(date '+%F %T')] FAIL(rc=$rc): $cmd" >> "$LOG_FILE"
  fi
  sleep 0.3
  return $rc
}

backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "${f}.bak.$(date +%s)"
    echo "[$(date '+%F %T')] BACKUP: $f -> ${f}.bak.*" >> "$LOG_FILE"
  fi
}
