#!/bin/bash

log() {
    echo -e "[\e[36m$(date '+%Y-%m-%d %H:%M:%S')\e[0m] $1"
}

error() {
    echo -e "[\e[31mERROR\e[0m] $1" >&2
}
