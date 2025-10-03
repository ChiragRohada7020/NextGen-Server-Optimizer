#!/bin/bash
source "$(dirname "$0")/utils.sh"

apply_qol() {
  echo -e "${CYAN}>>> Applying quality-of-life tweaks${NC}"
  # aliases
  cat > /etc/profile.d/nextgen_aliases.sh <<'EOF'
# NextGen aliases
alias update-all='sudo apt update && sudo apt upgrade -y'
alias lg='journalctl -xe --no-pager'
alias sysinfo='uname -a && lsb_release -a 2>/dev/null || true'
EOF
  chmod 644 /etc/profile.d/nextgen_aliases.sh

  # disable motd-news on Ubuntu if present
  if [[ -f /etc/default/motd-news ]]; then
    sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news || echo "ENABLED=0" > /etc/default/motd-news
  else
    echo "ENABLED=0" > /etc/default/motd-news
  fi

  echo "[$(date '+%F %T')] QOL done" >> "$LOG_FILE"
}
