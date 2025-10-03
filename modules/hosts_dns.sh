#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

fix_hosts_dns() {
    log "Starting: Fix Hosts & DNS"

    cp /etc/hosts /etc/hosts.bak.$(date +%s)
    if ! grep -q "127.0.1.1" /etc/hosts; then
        echo "127.0.1.1 $(hostname)" >> /etc/hosts
    fi

    cp /etc/resolv.conf /etc/resolv.conf.bak.$(date +%s)
    echo -e "nameserver 1.1.1.2\nnameserver 1.0.0.2" > /etc/resolv.conf

    log "Completed: Fix Hosts & DNS"
}
