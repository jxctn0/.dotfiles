if command -v zinit >/dev/null 2>&1; then
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light changyuheng/zsh-interactive-cd
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-history-substring-search
else
  echo "Zinit not found, skipping plugin loading"
  echo "Install Zinit with `sh -c \"$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)\"` or via Homebrew with `brew install zinit`"
  echo Install now? [Y/n]
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install zinit
    else
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
    fi
    echo "Zinit installed. Loading plugins..."
    # Re-run this file after installation
    source "$0"
  else
    echo "Skipping plugin installation. Please install Zinit and restart your terminal to enable plugins."
  fi
fi

bindkey '^0' zsh-interactive-cd

export ZSH_INTERACTIVE_CD_COMMAND="fd --type d | fzf --preview 'eza --icons --tree --level=2 {}'"
