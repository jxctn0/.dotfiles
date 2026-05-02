if command -v zinit >/dev/null 2>&1; then
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light changyuheng/zsh-interactive-cd
fi

bindkey '^0' zsh-interactive-cd

export ZSH_INTERACTIVE_CD_COMMAND="fd --type d | fzf --preview 'eza --icons --tree --level=2 {}'"
