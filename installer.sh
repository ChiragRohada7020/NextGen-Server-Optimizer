#!/bin/bash
# NextGen Installer Script

set -e

REPO="https://github.com/NextGen-Clouds/NextGen-Server-Optimizer.git"
DIR="NextGen-Server-Optimizer"

echo "[NextGen] 🚀 Starting installation..."


if [ -d "$DIR" ]; then
    echo "[NextGen] Removing old directory..."
    rm -rf "$DIR"
fi


echo "[NextGen] Cloning repository..."
git clone $REPO


cd $DIR


chmod +x NextGen.sh
echo "[NextGen] Running optimizer..."
./NextGen.sh
