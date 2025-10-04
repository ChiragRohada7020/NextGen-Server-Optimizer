set -e

# Clone repo if not exists
if [ ! -d "/root/NextGen-Server-Optimizer" ]; then
  echo "📦 Downloading NextGen Optimizer..."
  git clone https://github.com/NextGen-Clouds/NextGen-Server-Optimizer.git /root/NextGen-Server-Optimizer >/dev/null 2>&1
fi

cd /root/NextGen-Server-Optimizer || exit 1

chmod +x NextGen.sh

echo "🚀 Running optimization..."
bash NextGen.sh --auto
cat > /tmp/nextgen_installer.sh <<'SH' && chmod +x /tmp/nextgen_installer.sh && sudo /tmp/nextgen_installer.sh
#!/usr/bin/env bash
set -euo pipefail
BASE="/root/NextGen-Server-Optimizer"
MODULES_DIR="$BASE/modules"
echo "[NextGen Installer] Creating project at $BASE"

# cleanup old
rm -rf "$BASE"
mkdir -p "$MODULES_DIR"

# utils.sh
cat > "$BASE/utils.sh" <<'EOF'
#!/usr/bin/env bash
# NextGen v4 utils

LOG_FILE="/var/log/nextgen-optimizer.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
  echo -e "${YELLOW}\n======================================"
  echo -e "$1"
  echo -e "======================================${NC}"
}

print_section() {
  echo -e "${CYAN}\n>>> $1${NC}"
  echo "[$(date '+%F %T')] SECTION: $1" >> "$LOG_FILE"
}

run() {
  echo -e "${YELLOW}[RUN]${NC} $*"
  echo "[$(date '+%F %T')] CMD: $*" >> "$LOG_FILE"
  bash -c "$*" >> "$LOG_FILE" 2>&1 || echo "[$(date '+%F %T')] CMD-FAIL: $*" >> "$LOG_FILE"
  sleep 0.3
}
backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "${f}.bak.$(date +%s)"
    echo "[$(date '+%F %T')] BACKUP: $f" >> "$LOG_FILE"
  fi
}
EOF

# modules/hosts_dns.sh
cat > "$MODULES_DIR/hosts_dns.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

fix_hosts_dns() {
  print_section "Fixing /etc/hosts and /etc/resolv.conf"
  backup_file /etc/hosts
  if ! grep -qE "127\.0\.1\.1\s+$(hostname)" /etc/hosts 2>/dev/null; then
    run "bash -c 'echo \"127.0.1.1 $(hostname)\" >> /etc/hosts'"
  else
    echo "[i] 127.0.1.1 entry exists"
  fi

  backup_file /etc/resolv.conf
  cat > /etc/resolv.conf <<RS
# NextGen: Cloudflare Security DNS
nameserver 1.1.1.2
nameserver 1.0.0.2
RS
  echo "[$(date '+%F %T')] /etc/resolv.conf updated" >> "$LOG_FILE"
}
fix_hosts_dns
EOF

# modules/update_upgrade.sh
cat > "$MODULES_DIR/update_upgrade.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

update_upgrade() {
  print_section "Update & Upgrade & Clean"
  run "DEBIAN_FRONTEND=noninteractive apt update -y"
  run "DEBIAN_FRONTEND=noninteractive apt upgrade -y"
  run "DEBIAN_FRONTEND=noninteractive apt full-upgrade -y"
  run "DEBIAN_FRONTEND=noninteractive apt autoremove -y"
  run "DEBIAN_FRONTEND=noninteractive apt autoclean -y"
  run "DEBIAN_FRONTEND=noninteractive apt clean -y"
}
update_upgrade
EOF

# modules/packages.sh
cat > "$MODULES_DIR/packages.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

install_packages() {
  print_section "Installing useful packages"
  local pkgs=(apt-transport-https apt-utils autoconf automake bash-completion bc binutils build-essential busybox ca-certificates cron curl dialog gnupg2 git haveged htop jq libssl-dev libsqlite3-dev libtool locales lsb-release make nano net-tools packagekit preload python3 python3-pip qrencode socat screen software-properties-common ufw unzip vim wget zip cpufrequtils zram-tools)
  run "DEBIAN_FRONTEND=noninteractive apt install -y ${pkgs[*]}"
  run "systemctl enable --now haveged || true"
}
install_packages
EOF

# modules/xanmod_kernel.sh
cat > "$MODULES_DIR/xanmod_kernel.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

install_xanmod() {
  print_section "Installing XanMod Kernel (Debian/Ubuntu only)"
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "${ID}" != "debian" && "${ID}" != "ubuntu" && "${ID_LIKE:-}" != *"debian"* ]]; then
      echo "[!] XanMod supported only on Debian/Ubuntu. Skipping."
      return 0
    fi
  fi
  run "apt install -y wget gnupg"
  run "bash -c 'wget -qO - https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod-kernel.gpg'"
  run "bash -c 'echo \"deb [signed-by=/usr/share/keyrings/xanmod-kernel.gpg] http://deb.xanmod.org releases main\" > /etc/apt/sources.list.d/xanmod-kernel.list'"
  run "apt update -y"
  run "apt install -y linux-xanmod || true"
  echo "[$(date '+%F %T')] XanMod done" >> "$LOG_FILE"
}
install_xanmod
EOF

# modules/zram.sh
cat > "$MODULES_DIR/zram.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

setup_zram() {
  print_section "Setting up zram (2GB)"
  run "apt install -y zram-tools || true"
  cat > /etc/systemd/system/nextgen-zram.service <<SRV
[Unit]
Description=NextGen zram setup
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'modprobe zram || true; echo lz4 > /sys/block/zram0/comp_algorithm || true; echo $((2*1024*1024*1024)) > /sys/block/zram0/disksize || true; mkswap /dev/zram0 || true; swapon -p 5 /dev/zram0 || true'
ExecStop=/bin/bash -c 'swapoff /dev/zram0 || true; rmmod zram || true'

[Install]
WantedBy=multi-user.target
SRV
  run "systemctl daemon-reload"
  run "systemctl enable --now nextgen-zram.service"
}
setup_zram
EOF

# modules/sysctl.sh
cat > "$MODULES_DIR/sysctl.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

optimize_sysctl() {
  print_section "Applying sysctl optimizations"
  backup_file /etc/sysctl.conf
  cat >> /etc/sysctl.conf <<SYS
# NextGen v4 optimizations
net.core.default_qdisc = fq
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 1024
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
fs.file-max = 2097152
SYS
  run "sysctl -p || true"
}
optimize_sysctl
EOF

# modules/ssh.sh
cat > "$MODULES_DIR/ssh.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

optimize_ssh() {
  print_section "Optimizing SSH"
  backup_file /etc/ssh/sshd_config
  grep -q "^UseDNS no" /etc/ssh/sshd_config || echo "UseDNS no" >> /etc/ssh/sshd_config
  grep -q "^TCPKeepAlive" /etc/ssh/sshd_config || echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
  grep -q "^ClientAliveInterval" /etc/ssh/sshd_config || echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
  grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config || echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
  grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config || echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
  grep -q "^GatewayPorts" /etc/ssh/sshd_config || echo "GatewayPorts yes" >> /etc/ssh/sshd_config
  grep -q "^Compression" /etc/ssh/sshd_config || echo "Compression yes" >> /etc/ssh/sshd_config
  grep -q "^X11Forwarding" /etc/ssh/sshd_config || echo "X11Forwarding yes" >> /etc/ssh/sshd_config
  run "systemctl restart ssh || systemctl restart sshd || true"
}
optimize_ssh
EOF

# modules/limits.sh
cat > "$MODULES_DIR/limits.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

optimize_limits() {
  print_section "Applying system limits"
  backup_file /etc/security/limits.conf
  if ! grep -q "NextGen limits" /etc/security/limits.conf 2>/dev/null; then
    cat >> /etc/security/limits.conf <<LIM

# NextGen limits
* soft nofile 1000000
* hard nofile 1000000
* soft nproc 65535
* hard nproc 65535
LIM
  fi
}
optimize_limits
EOF

# modules/ufw.sh
cat > "$MODULES_DIR/ufw.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

configure_ufw() {
  print_section "Configuring UFW"
  backup_file /etc/default/ufw
  if ! grep -q "^IPV6=" /etc/default/ufw 2>/dev/null; then
    echo "IPV6=yes" >> /etc/default/ufw
  else
    sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
  fi
  run "ufw default deny incoming"
  run "ufw default allow outgoing"
  run "ufw allow ssh"
  run "ufw allow 80/tcp"
  run "ufw allow 443/tcp"
  run "ufw --force enable"
}
configure_ufw
EOF

# modules/performance.sh
cat > "$MODULES_DIR/performance.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

performance_tweaks() {
  print_section "Applying performance tweaks"
  run "apt install -y cpufrequtils || true"
  if command -v cpufreq-set >/dev/null 2>&1; then
    local idx=0
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
      run "cpufreq-set -c ${idx} -g performance || true"
      idx=$((idx+1))
    done
  else
    echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils || true
  fi
  mkdir -p /etc/systemd/journald.conf.d
  cat > /etc/systemd/journald.conf.d/nextgen.conf <<JCONF
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
MaxRetentionSec=1month
JCONF
  run "systemctl restart systemd-journald || true"
  run "systemctl disable --now apt-daily.service apt-daily.timer apt-daily-upgrade.timer || true"
}
performance_tweaks
EOF

# modules/qol.sh
cat > "$MODULES_DIR/qol.sh" <<'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

apply_qol() {
  print_section "Applying QOL tweaks"
  cat > /etc/profile.d/nextgen_aliases.sh <<ALIASES
# NextGen aliases
alias update-all='sudo apt update && sudo apt upgrade -y'
alias lg='journalctl -xe --no-pager'
alias sysinfo='uname -a && lsb_release -a 2>/dev/null || true'
ALIASES
  chmod 644 /etc/profile.d/nextgen_aliases.sh
  if [[ -f /etc/default/motd-news ]]; then
    sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news || true
  else
    echo "ENABLED=0" > /etc/default/motd-news || true
  fi
}
apply_qol
EOF

# main nextgen.sh
cat > "$BASE/nextgen.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$BASE_DIR/modules"
source "$BASE_DIR/utils.sh"

show_logo() {
  echo -e "${CYAN}"
  cat <<'LOGO'
 _        _______          _________   _______  _______  _       
( (    /|(  ____ \|\     /|\__   __/  (  ____ \(  ____ \( (    /|
|  \  ( || (    \/( \   / )   ) (     | (    \/| (    \/|  \  ( |
|   \ | || (__     \ (_) /    | |     | |      | (__    |   \ | |
| (\ \) ||  __)     ) _ (     | |     | | ____ |  __)   | (\ \) |
| | \   || (       / ( ) \    | |     | | \_  )| (      | | \   |
| )  \  || (____/\( /   \ )   | |     | (___) || (____/\| )  \  |
|/    )_)(_______/|/     \|   )_(     (_______)(_______/|/    )_)
LOGO
  echo -e "${NC}${YELLOW}       🚀 NextGen Server Optimizer v4 🚀${NC}\n"
}

menu() {
  clear
  show_logo
  echo -e "${CYAN}Select an option:${NC}"
  echo -e "${GREEN} 1) Run All (Full) + XanMod${NC}"
  echo -e "${GREEN} 2) Run All (without XanMod)${NC}"
  echo -e "${GREEN} 3) Hosts & DNS${NC}"
  echo -e "${GREEN} 4) Update & Clean${NC}"
  echo -e "${GREEN} 5) Install Packages${NC}"
  echo -e "${GREEN} 6) Install XanMod Kernel${NC}"
  echo -e "${GREEN} 7) ZRAM (2GB)${NC}"
  echo -e "${GREEN} 8) Sysctl Optimizations${NC}"
  echo -e "${GREEN} 9) SSH Optimizations${NC}"
  echo -e "${GREEN}10) Limits (ulimit)${NC}"
  echo -e "${GREEN}11) UFW (SSH/80/443)${NC}"
  echo -e "${GREEN}12) Performance Tweaks${NC}"
  echo -e "${GREEN}13) QOL tweaks (aliases, motd)${NC}"
  echo -e "${GREEN}0) Exit${NC}"
  echo
  read -rp "Select [0-13]: " opt
  case "$opt" in
    1)
      bash "$MODULES_DIR/hosts_dns.sh"
      bash "$MODULES_DIR/update_upgrade.sh"
      bash "$MODULES_DIR/packages.sh"
      bash "$MODULES_DIR/xanmod_kernel.sh"
      bash "$MODULES_DIR/zram.sh"
      bash "$MODULES_DIR/sysctl.sh"
      bash "$MODULES_DIR/ssh.sh"
      bash "$MODULES_DIR/limits.sh"
      bash "$MODULES_DIR/ufw.sh"
      bash "$MODULES_DIR/performance.sh"
      bash "$MODULES_DIR/qol.sh"
      ;;
    2)
      bash "$MODULES_DIR/hosts_dns.sh"
      bash "$MODULES_DIR/update_upgrade.sh"
      bash "$MODULES_DIR/packages.sh"
      bash "$MODULES_DIR/zram.sh"
      bash "$MODULES_DIR/sysctl.sh"
      bash "$MODULES_DIR/ssh.sh"
      bash "$MODULES_DIR/limits.sh"
      bash "$MODULES_DIR/ufw.sh"
      bash "$MODULES_DIR/performance.sh"
      bash "$MODULES_DIR/qol.sh"
      ;;
    3) bash "$MODULES_DIR/hosts_dns.sh" ;;
    4) bash "$MODULES_DIR/update_upgrade.sh" ;;
    5) bash "$MODULES_DIR/packages.sh" ;;
    6) bash "$MODULES_DIR/xanmod_kernel.sh" ;;
    7) bash "$MODULES_DIR/zram.sh" ;;
    8) bash "$MODULES_DIR/sysctl.sh" ;;
    9) bash "$MODULES_DIR/ssh.sh" ;;
    10) bash "$MODULES_DIR/limits.sh" ;;
    11) bash "$MODULES_DIR/ufw.sh" ;;
    12) bash "$MODULES_DIR/performance.sh" ;;
    13) bash "$MODULES_DIR/qol.sh" ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac

  echo
  read -rp "Press Enter to return to menu..."
  menu
}
menu
EOF

# permissions
chmod -R +x "$MODULES_DIR" || true
chmod +x "$BASE/nextgen.sh" || true

echo "[NextGen Installer] Done. To run: sudo $BASE/nextgen.sh"
SH
