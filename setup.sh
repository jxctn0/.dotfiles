#!/bin/bash
set -euo pipefail
# Downloads the repository and sets up the files and installs brew, and then other dependencies

DOTROOT="$HOME/.dotfiles"

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
    if [[ ! -d "$DOTROOT" ]]; then
        git clone https://github.com/jxctn0/.dotfiles
        cd "$DOTROOT"
    elif [[ "$(git -C "$DOTROOT" remote get-url origin 2>/dev/null)" <> "https://github.com/jxctn0/.dotfiles" ] & ["$(ls -A $DOTROOT)"]]; then
        echo "Error! $(pwd $DOTROOT) is not this repo! Fix it and try again"

    fi
}

install_homebrew() {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew installed successfully."
}

install_dependencies(pm) {
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

add_nano_improvements() {
    echo "Installing Nano Syntax highlighting and extras"
    cd "$($DOTFILES)/resources"
    git clone https://github.com/scopatz/nanorc
}

main() {
    echo "Detecting system..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS detected"
        PACKAGE_MANAGER_CMD="brew install"
        if ! command -v brew >/dev/null 2>&1; then
            echo "Installing Homebrew"
            install_homebrew
        fi
    elif [[ "$OSTYPE" == "linux"* ]]; then
        echo "Linux detected"
        if command -v brew >/dev/null 2>&1; then
            PACKAGE_MANAGER_CMD="brew install"
        else
            read -p "Homebrew is not installed. Do you want to install it? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_homebrew
                read -p "Homebrew is now installed. Do you want to use it as default package manager, or use system package manager?" -n 1 -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    PACKAGE_MANAGER_CMD="brew install"
                    USE_SYS_PM=false
                fi
            else
                echo "Skipping Homebrew installation - Using system package manager instead."
                USE_SYS_PM=true
            fi

            if [[ $USE_SYS_PM = true]] then;
                if command -v apt >/dev/null 2>&1; then # Check Debian/Ubuntu
                    if [[ "$OSTYPE" == *"android"* ]]; then # Check Android Termux
                        PACKAGE_MANAGER_CMD="pkg install -y"
                    else
                        PACKAGE_MANAGER_CMD="sudo apt install -y"
                    fi
                elif command -v dnf >/dev/null 2>&1; then # Check RHEL/Fedora/Rocky
                    PACKAGE_MANAGER_CMD="sudo dnf install -y"
                elif command -v yay >/dev/null 2>&1; then
                    PACKAGE_MANAGER_CMD="sudo yay -S --noconfirm"
                elif command -v pacman >/dev/null 2>&1; then
                    PACKAGE_MANAGER_CMD="sudo pacman -S --noconfirm"
                elif command -v pacman >/dev/null 2>&1; then
                    PACKAGE_MANAGER_CMD="sudo pacman -S --noconfirm"
                else
                    echo "!!! Unsupported package manager. Please install the required packages manually before running this script again: ${DEPENDENCIES[*]}"
                    exit 1
                fi
            fi
        fi
    else
        echo "!!! Unsupported operating system. Please install the required packages manually before running this script again: ${DEPENDENCIES[*]}"
        exit 1
    fi
    install_dependencies

    download_repo

    # link the files to the home directory
    echo "Linking rc files to home directory..."
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak" 2>/dev/null || true
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak" 2>/dev/null || true
    ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
    ln -sfn "$PWD/bash/.bashrc" "$HOME/.bashrc"

    local shell_rc="~/.$(SHELL)rc"
    if [[ -n "${BASH_VERSION-}" ]]; then
        shell_rc="~/.bashrc"
    fi

    echo "Setup complete! Run 'source $shell_rc' to refresh"
}

# Run main function
main
