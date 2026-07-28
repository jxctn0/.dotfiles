#!/bin/bash
set -euo pipefail

echo "🚀 Quick Shell Setup starting..."

OS="$(uname -s)"

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
  echo "macOS detected"

  if ! have brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "Installing core tools (brew)..."
  brew install git fzf ripgrep fd eza lazygit tmux btop zoxide

  echo "Installing Brewfile"
  wget https://raw.githubusercontent.com/jxctn0/brewdump/refs/heads/main/Brewfile -O "/tmp/Brewfile"
  brew bundle
  rm "/tmp/Brewfile"

}


install_linux() {
  echo "Linux detected"

  local PACKAGE_MANAGER=""

  local NEEDED_PACKAGES=(
    git
    fzf
    ripgrep
    tmux
    htop
    btop
    curl
    unzip
    wget
  )

  # Ask if user wants to install homebrew on Linux
  if ! have brew; then
    read -p "Homebrew is not installed. Do you want to install it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo "Homebrew installed successfully."
    else
      echo "Skipping Homebrew installation - Using system package manager instead."
       if have apt; then
    PACKAGE_MANAGER="apt install -y"
  elif have dnf; then
    PACKAGE_MANAGER="dnf install -y"
  elif have pacman; then
    PACKAGE_MANAGER="pacman -S --noconfirm"
  else
    echo "!!! Unsupported package manager. Please install the required packages manually before running this script again: ${NEEDED_PACKAGES[*]}"
    exit 1
  fi
    fi
  fi

 

  echo "Installing core tools ($PACKAGE_MANAGER)..."

  $PACKAGE_MANAGER "${NEEDED_PACKAGES[@]}"

}

echo "Detecting system..."

case "$OS" in
  Darwin) install_mac ;;
  Linux) install_linux ;;
  *)
    echo "!!! Unsupported OS: $OS"
    exit 1
    ;;
esac

echo ""
echo "Done installing base tools!"
echo ""
echo "Restart shell/terminal to apply changes."
echo ""
