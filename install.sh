#!/bin/bash
# NextGen Server Optimizer - Installation Script

set -e

VERSION="2.0.0"
INSTALL_DIR="/opt/nextgen"
MODULES_DIR="$INSTALL_DIR/modules"
BIN_DIR="/usr/local/bin"
LOG_DIR="/var/log/nextgen"
CONFIG_DIR="/etc/nextgen"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║         NextGen Server Optimizer          ║
║                v2.0.0                     ║
║          Installation Script              ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root: sudo ./install.sh${NC}"
    exit 1
fi

# Check system
echo -e "${BLUE}🔍 Checking system compatibility...${NC}"
if [ ! -f /etc/redhat-release ] && [ ! -f /etc/debian_version ]; then
    echo -e "${YELLOW}⚠️  Warning: Unsupported Linux distribution${NC}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create directories
echo -e "${BLUE}📁 Creating directories...${NC}"
mkdir -p "$MODULES_DIR" "$LOG_DIR" "$CONFIG_DIR" "$CONFIG_DIR/backups"

# Copy files
echo -e "${BLUE}📦 Copying files...${NC}"
cp modules/*.sh "$MODULES_DIR/"
cp nextgen-optimizer "$BIN_DIR/"
[ -d config ] && cp config/* "$CONFIG_DIR/" 2>/dev/null || true

# Set permissions
echo -e "${BLUE}🔒 Setting permissions...${NC}"
chmod +x "$BIN_DIR/nextgen-optimizer" "$MODULES_DIR"/*.sh

# Create log files
for log in nextgen kernel network storage security services nginx; do
    touch "$LOG_DIR/$log.log"
    chmod 644 "$LOG_DIR/$log.log"
done

# Install dependencies
echo -e "${BLUE}📥 Installing dependencies...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y sysstat iotop htop curl wget
elif command -v yum &> /dev/null; then
    yum install -y sysstat iotop htop curl wget
elif command -v dnf &> /dev/null; then
    dnf install -y sysstat iotop htop curl wget
fi

# Create backups
echo -e "${BLUE}💾 Creating backups...${NC}"
[ -f /etc/sysctl.conf ] && cp /etc/sysctl.conf "$CONFIG_DIR/backups/sysctl.conf.backup.$(date +%Y%m%d)"
[ -f /etc/security/limits.conf ] && cp /etc/security/limits.conf "$CONFIG_DIR/backups/limits.conf.backup.$(date +%Y%m%d)"

echo -e "${GREEN}✅ Installation completed!${NC}"
echo -e "${BLUE}Usage: sudo nextgen-optimizer --help${NC}"
