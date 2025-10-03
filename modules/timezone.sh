#!/bin/bash
source "$(dirname "$0")/utils.sh"

set_timezone_from_ip() {
  echo -e "${CYAN}>>> Detecting timezone from IP and setting system timezone${NC}"
  local tz
  tz="$(curl -fsS --max-time 8 https://ipapi.co/timezone 2>/dev/null || true)"
  if [[ -z "$tz" ]]; then
    tz="$(curl -fsS --max-time 8 https://ipinfo.io/timezone 2>/dev/null || true)"
  fi
  if [[ -n "$tz" ]]; then
    run "timedatectl set-timezone $tz"
    echo "[$(date '+%F %T')] Timezone set to $tz" >> "$LOG_FILE"
  else
    echo "[!] Could not auto-detect timezone. Skipping (keeps current timezone)."
  fi
}
