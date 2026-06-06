# =========================
# Prompt configuration
# =========================

autoload -U colors && colors

function icon_pick() {
  local nficon="$1"
  local emoji="$2"
  local fallback="${3:-@}"

  if [[ "$NERDFONT_ENABLED" == true ]]; then
    echo "$nficon"
  elif [[ "$EMOJI_FALLBACK" == true && "$NERDFONT_ENABLED" == false ]]; then
    echo "$emoji"
  else
    echo "$fallback"
  fi
}

# Define the distro icons in a Zsh associative array for quick lookups
typeset -A DISTRO_ICONS
DISTRO_ICONS=(
  aix " "
  almalinux " "
  alpaquita " "
  alpine " "
  altlinux " "
  amazon " "
  android " "
  aosc " "
  arch " "
  artix " "
  bluefin " "
  cachyos " "
  centos " "
  debian " "
  dragonfly " "
  elementary " "
  emscripten " "
  endeavouros " "
  fedora " "
  freebsd " "
  garuda " "
  gentoo " "
  hardenedbsd "󰞌 "
  illumos " "
  instantos " "
  ios "󰀷 "
  kali " "
  linux " "
  mabox " "
  macos " "
  manjaro " "
  mariner " "
  midnightbsd " "
  mint " "
  netbsd " "
  nixos " "
  nobara " "
  openbsd " "
  opencloudos " "
  openeuler " "
  opensuse " "
  oraclelinux "󰺡 "
  pikaos " "
  pop " "
  raspbian " "
  redhat "󱄛 "
  redhatenterprise "󱄛 "
  redox "󰀘 "
  rockylinux " "
  solus " "
  suse " "
  ubuntu " "
  ultramarine " "
  unknown " "
  uos " "
  void " "
  windows "󰍲 "
  zorin " "
)

# (Prompt provider will be loaded after defaults are assigned so it can override them)

# Check if running on container:
IS_CONTAINER=false

isContainer() {
    if command -v findmnt &> /dev/null; then
        if findmnt / | grep -qE 'overlay|containerd|docker'; then
            IS_CONTAINER=true
            return 0
        fi
    fi

    if [ "$(stat -c %i / 2>/dev/null)" != "2" ] && [ "$(stat -c %i / 2>/dev/null)" != "" ]; then
        IS_CONTAINER=true
        return 0
    fi

    if [ -f /.dockerenv ]; then
        IS_CONTAINER=true
        return 0
    fi

    if [ -f /proc/self/cgroup ] && grep -qi 'docker\|lxc\|kubepods\|containerd' /proc/self/cgroup; then
        IS_CONTAINER=true
        return 0
    fi

    IS_CONTAINER=false
    return 1
}

# Run the container check immediately
isContainer

CONTAINER_RUNTIME="unknown"

CONTAINER_TYPE() {
    if [ "$IS_CONTAINER" != true ]; then
        CONTAINER_RUNTIME="none (host/VM)"
        return 1
    fi

    if [ -n "$container" ] && [ "$container" = "podman" ]; then
        CONTAINER_RUNTIME="podman"
        return 0
    fi
    if grep -q "podman" /proc/self/environ 2>/dev/null; then
        CONTAINER_RUNTIME="podman"
        return 0
    fi

    if [ -f /.dockerenv ] || [ -f /.dockerinit ]; then
        CONTAINER_RUNTIME="docker"
        return 0
    fi

    if findmnt / 2>/dev/null | grep -q "containerd"; then
        if [ -d /var/run/secrets/kubernetes.io ] || [ -n "$KUBERNETES_SERVICE_HOST" ]; then
            CONTAINER_RUNTIME="kubernetes (containerd)"
        else
            CONTAINER_RUNTIME="containerd"
        fi
        return 0
    fi

    if [ -f /dev/lxc ] || grep -qa "lxc" /proc/1/environ 2>/dev/null; then
        CONTAINER_RUNTIME="lxc"
        return 0
    fi
    if [ -n "$container" ] && [ "$container" = "lxc" ]; then
        CONTAINER_RUNTIME="lxc"
        return 0
    fi

    if [ -n "$container" ] && [ "$container" = "systemd-nspawn" ]; then
        CONTAINER_RUNTIME="systemd-nspawn"
        return 0
    fi

    CONTAINER_RUNTIME="generic-container"
    return 0
}

detect_distro(){
  DISTRO_NAME="linux"

  if [[ -f /etc/os-release ]]; then
    # Source os-release in a subshell to avoid polluting environment variables
    DISTRO_NAME=$(basename "$(sh -c '. /etc/os-release; echo ${ID:-linux}')")
  fi

  # Fallback to general Linux icon if Nerd Fonts are off
  local default_icon=$(icon_pick "" "🐧" "@")
  
  # Check if Nerd Fonts are enabled. If so, pull from our associative array map.
  if [[ "$NERDFONT_ENABLED" == true ]]; then
    # Look up lowercase ID in the array, fallback to "linux" icon if not found
    DISTRO_ICON="${DISTRO_ICONS[$DISTRO_NAME]:-${DISTRO_ICONS[linux]}}"
  else
    DISTRO_ICON="$default_icon"
  fi
}

# -------------------------
# Distrobox / container prompt
# -------------------------
if [[ "$IS_CONTAINER" == true ]]; then
  CONTAINER_TYPE # Run detection to set CONTAINER_RUNTIME
  detect_distro   # Run to get container's inner distro name/icon

  case "$CONTAINER_RUNTIME" in
    "kubernetes (containerd)") CONTAINER_ICON="" ;;
    "podman")                  CONTAINER_ICON="" ;;
    "docker")                  CONTAINER_ICON="" ;;
    *)                         CONTAINER_ICON="" ;; # Catch-all fallback for other container runtimes
  esac

  PROMPT="%F{magenta}${CONTAINER_ICON}%f %F{cyan}%n%f %F{cyan}${DISTRO_ICON} ${DISTRO_NAME}%f-%F{blue}%m%f %# "
  RPROMPT=""

# -------------------------
# Normal shell
# -------------------------
else
  KERN_TYPE=$(uname)

  if [[ "$KERN_TYPE" == "Darwin" ]]; then
    DISTRO_NAME="macos"
    DISTRO_ICON=$(icon_pick "" "🍏" "Mac") 
  elif [[ "$KERN_TYPE" == "Linux" ]]; then
    detect_distro # sets $DISTRO_NAME and $DISTRO_ICON
  fi

  PROMPT="%F{cyan}%n%f %F{cyan}${DISTRO_ICON} ${DISTRO_NAME}%f-%F{blue}%m%f %# "
  RPROMPT=""
fi

# Load prompt provider if specified in variables.zsh (do this last so provider can override defaults)
if [[ -n "$PROMPT_PROVIDER" ]]; then 
  [[ -f "$DOTFILES/prompt_providers/$PROMPT_PROVIDER" ]] && source "$DOTFILES/prompt_providers/$PROMPT_PROVIDER"
fi