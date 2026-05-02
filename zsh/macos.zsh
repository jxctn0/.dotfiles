# macOS only config

command -v brew >/dev/null && eval "$(brew shellenv)"

[[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]] && \
  source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

[[ -f /usr/local/opt/zinit/zinit.zsh ]] && \
  source /usr/local/opt/zinit/zinit.zsh

export NVM_DIR="$HOME/.nvm"
[[ -s "/usr/local/opt/nvm/nvm.sh" ]] && source "/usr/local/opt/nvm/nvm.sh"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

command -v brew >/dev/null && alias nano="$(brew --prefix)/bin/nano"
