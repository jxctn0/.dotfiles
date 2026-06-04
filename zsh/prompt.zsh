# =========================
# Prompt configuration
# =========================

autoload -U colors && colors


# -------------------------
# Distrobox / container prompt
# -------------------------
if [[ -n "$CONTAINER_ID" ]]; then

  ICON=""

  # Detect distro icon + name
  DISTRO_ICON=""
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

  [[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]] && \
    source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

  [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi

