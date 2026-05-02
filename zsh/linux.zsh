# Linux / container safe config

export EDITOR="nano"

command -v apt >/dev/null && alias update="sudo apt update && sudo apt upgrade"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
