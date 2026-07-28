#!/bin/bash
set -euo pipefail
# Downloads the repository and sets up the files and installs brew, and then other dependencies

DEPENDENCIES=(
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

PACKAGE_MANAGER_CMD=""

download_repo() {
  echo "Downloading repository..."
  git clone https://github.com/jxctn0/.dotfiles
  cd .dotfiles
}

install_homebrew() {
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed successfully."
}

install_dependencies() {
    echo "Installing core tools ($PACKAGE_MANAGER_CMD)..."
    $PACKAGE_MANAGER_CMD "${DEPENDENCIES[@]}"
}

main() {
  echo "Detecting system..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected"
    PACKAGE_MANAGER_CMD="brew install"
    if ! command -v brew >/dev/null 2>&1; then
      install_homebrew
    fi
    install_dependencies
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux detected"
    if command -v brew >/dev/null 2>&1; then
      PACKAGE_MANAGER_CMD="brew install"
    else
      read -p "Homebrew is not installed. Do you want to install it? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_homebrew
        PACKAGE_MANAGER_CMD="brew install"
      else
        echo "Skipping Homebrew installation - Using system package manager instead."
        if command -v apt >/dev/null 2>&1; then
            PACKAGE_MANAGER_CMD="sudo apt install -y"
        elif command -v dnf >/dev/null 2>&1; then
            PACKAGE_MANAGER_CMD="sudo dnf install -y"
        elif command -v pacman >/dev/null 2>&1; then
            PACKAGE_MANAGER_CMD="sudo pacman -S --noconfirm"
        else
            echo "!!! Unsupported package manager. Please install the required packages manually before running this script again: ${DEPENDENCIES[*]}"
            exit 1
        fi
      fi
    fi
    install_dependencies
  else
    echo "!!! Unsupported operating system. Please install the required packages manually before running this script again: ${DEPENDENCIES[*]}"
    exit 1
  fi

  download_repo

  # link the files to the home directory
  echo "Linking rc files to home directory..."
  ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
  ln -sfn "$PWD/bash/.bashrc" "$HOME/.bashrc"

    echo "Setup complete!"
}


# Run main function
main