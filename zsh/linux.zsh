#!/usr/bin/env bash

# Get Package manager definitions
# Maps to: PKG_CMD (command), PKG_INSTALL (install), PKG_UPDATE (update), PKG_LIST (list)

if command -v apt >/dev/null 2>&1; then
    if [[ "$OSTYPE" == *"android"* ]]; then 
        # Android Termux
        PKG_CMD="pkg"
        PKG_INSTALL="pkg install -y"
        PKG_UPDATE="pkg upgrade -y"
        PKG_LIST="pkg list-installed"
    else
        # Debian/Ubuntu
        PKG_CMD="apt"
        PKG_INSTALL="sudo apt install -y"
        PKG_UPDATE="sudo apt update && sudo apt upgrade -y"
        PKG_LIST="apt list --installed"
    fi
elif command -v pacman >/dev/null 2>&1; then
    # Arch Linux / Manjaro
    PKG_CMD="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
    PKG_UPDATE="sudo pacman -Syu --noconfirm"
    PKG_LIST="pacman -Q"
elif command -v dnf >/dev/null 2>&1; then
    # Fedora / RHEL 8+
    PKG_CMD="dnf"
    PKG_INSTALL="sudo dnf install -y"
    PKG_UPDATE="sudo dnf upgrade -y"
    PKG_LIST="dnf list installed"
elif command -v yum >/dev/null 2>&1; then
    # Older RHEL / CentOS
    PKG_CMD="yum"
    PKG_INSTALL="sudo yum install -y"
    PKG_UPDATE="sudo yum update -y"
    PKG_LIST="yum list installed"
elif command -v apk >/dev/null 2>&1; then
    # Alpine Linux
    PKG_CMD="apk"
    PKG_INSTALL="sudo apk add"
    PKG_UPDATE="sudo apk update && sudo apk upgrade"
    PKG_LIST="apk info"
else
    # Unrecognised package manager
    PKG_CMD="unknown"
    PKG_INSTALL="unknown"
    PKG_UPDATE="unknown"
    PKG_LIST="unknown"
    echo "Warning: Unrecognised package manager." >&2
fi

export PKG_CMD PKG_INSTALL PKG_UPDATE PKG_LIST