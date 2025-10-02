#!/bin/bash


GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

log_success() {
    echo -e "${GREEN}[✔] $1${RESET}"
}

log_error() {
    echo -e "${RED}[✘] $1${RESET}"
}

log_info() {
    echo -e "${YELLOW}[i] $1${RESET}"
}
