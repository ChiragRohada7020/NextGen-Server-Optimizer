#!/bin/bash
echo "Installing NextGen Server Optimizer..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Create directories
mkdir -p /opt/nextgen/modules
mkdir -p /var/log/nextgen

# Copy modules
cp modules/*.sh /opt/nextgen/modules/
cp nextgen-optimizer /usr/local/bin/
chmod +x /usr/local/bin/nextgen-optimizer
chmod +x /opt/nextgen/modules/*.sh

echo "Installation completed!"
echo "Run: nextgen-optimizer --help"
