#!/usr/bin/zsh
# =========================
# Zsh entry point
# =========================

export DOTFILES="$HOME/.dotfiles/zsh"


# Load OS-specific config
if [[ "$OSTYPE" == "darwin"* ]]; then
  [[ -f "$DOTFILES/macos.zsh" ]] && source "$DOTFILES/macos.zsh"
else
  [[ -f "$DOTFILES/linux.zsh" ]] && source "$DOTFILES/linux.zsh"
fi

# Get name to each file, filter out ones that dont start with a number, source by number i.e. 00-zshrc, 01-p10k.zsh, 02-plugins.zsh, etc.
local n=0
for file in "$DOTFILES"/[0-9]*-*.zsh(N); do
  source "$file"
  n=$((n + 1))
done
echo "Sourced $n files from $DOTFILES"
