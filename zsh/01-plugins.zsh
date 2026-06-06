if command -v zinit >/dev/null 2>&1; then
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light changyuheng/zsh-interactive-cd
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-history-substring-search
  zinit light starship/starship
else
  echo "Zinit not found, skipping plugin loading."
  echo "To install Zinit, run:"
  echo "  brew install zinit"
  echo "or:"
  echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)\""
fi

bindkey '^0' zsh-interactive-cd

export ZSH_INTERACTIVE_CD_COMMAND="fd --type d | fzf --preview 'eza --icons --tree --level=2 {}'"
