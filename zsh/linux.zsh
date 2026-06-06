# Linux / container safe config

export EDITOR="nano"

if command -v apt >/dev/null 2>&1; then
  export DISTRO_PACKAGE_MANAGER="apt"
elif command -v pacman >/dev/null 2>&1; then
  export DISTRO_PACKAGE_MANAGER="pacman"
elif command -v dnf >/dev/null 2>&1; then
  export DISTRO_PACKAGE_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
  export DISTRO_PACKAGE_MANAGER="yum"
elif command -v apk >/dev/null 2>&1; then
  export DISTRO_PACKAGE_MANAGER="apk"
else
  export DISTRO_PACKAGE_MANAGER="unknown"
fi

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
