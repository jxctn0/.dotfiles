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
    unzip
    wget
    curl
)

package_command_for() {
    case "$1" in
        ripgrep) printf '%s' rg ;;
        *) printf '%s' "$1" ;;
    esac
}

PACKAGE_MANAGER_CMD=""

download_repo() {
  echo "Downloading repository..."
  if [[ ! -d "$HOME/.dotfiles" ]]; then
    git clone https://github.com/jxctn0/.dotfiles "$HOME/.dotfiles"
  fi
  cd "$HOME/.dotfiles"
}

install_homebrew() {
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed successfully."
}

install_dependencies() {
    local missing=()

    for dep in "${DEPENDENCIES[@]}"; do
        local check_cmd
        check_cmd=$(package_command_for "$dep")
        if ! command -v "$check_cmd" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "All dependencies are already installed."
        return
    fi

    echo "Installing missing dependencies: ${missing[*]}"
    $PACKAGE_MANAGER_CMD "${missing[@]}"
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
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak" 2>/dev/null || true
  mv "$HOME/.bashrc" "$HOME/.bashrc.bak" 2>/dev/null || true
  ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
  ln -sfn "$PWD/bash/.bashrc" "$HOME/.bashrc"

  local shell_rc="~/.zshrc"
  if [[ -n "${BASH_VERSION-}" ]]; then
      shell_rc="~/.bashrc"
  fi

  echo "Setup complete! Run 'source $shell_rc' to refresh"
}

# Run main function
main