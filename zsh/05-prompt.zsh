# =========================
# Prompt configuration
# =========================

autoload -U colors && colors

function icon_pick() {
  local nficon="$1"
  local emoji="$2"
  local fallback="$3"

  if [[ "$NERDFONT_ENABLED" == true ]]; then
    echo "$nficon"
  elif [[ "$EMOJI_FALLBACK" == true && "$NERDFONT_ENABLED" == false ]]; then
    echo "$emoji"
  else
    echo "$fallback"
  fi
}

# automatically load prompt provider if specified in variables.zsh
if [[ -n "$PROMPT_PROVIDER" ]]; then # Load prompt provider if specified
  [[ -f "$DOTFILES/prompt_providers/$PROMPT_PROVIDER" ]] && source "$DOTFILES/prompt_providers/$PROMPT_PROVIDER"
fi

# if not, load default prompt (container + distro info if in a container, otherwise "nice" format including nerd font icons if available)

# -------------------------
# Distrobox / container prompt
# -------------------------
if [[ -n "$IS_CONTAINER" ]]; then
  ICON=$(icon_pick "" "🐳" "[container]")

  # Detect distro icon + name
  DISTRO_ICON=$( icon_pick "" "🐧" "@" ) # uses @ since will usually be in that place
  DISTRO_NAME="linux"

  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_NAME=${ID:-linux}

    case "$ID" in
      debian)  DISTRO_ICON="" ;;
      ubuntu)  DISTRO_ICON="" ;;
      pop_os)   DISTRO_ICON="" ;;
      fedora)  DISTRO_ICON="" ;;
      arch)    DISTRO_ICON="" ;;
      alpine)   DISTRO_ICON="" ;;
      *)       DISTRO_ICON="" ;;
    esac
  fi

  PROMPT="%F{magenta}${ICON}%f %F{cyan}%n%f %F{cyan}${DISTRO_ICON} ${DISTRO_NAME}%f-%F{blue}%m%f %# "
  RPROMPT=""

  return
fi


# -------------------------
# Normal shell (Powerlevel10k)
# -------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
  elif [[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
  fi

  [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi