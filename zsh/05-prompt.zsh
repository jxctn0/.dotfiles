# [
# Zsh Prompt Configuration Script
# ]

if [[ "$USE_CUSTOM_PROVIDER" == false ]]; then

    autoload -U colors && colors

    # :
    # Name: icon_pick
    # Purpose: Returns an icon based on Nerd Font and Emoji availability flags
    # Inputs: $1 (Nerd Font Icon), $2 (Emoji), $3 (Fallback Text)
    #
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

    # =
    # Distro icons associative array map
    #
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

    # =
    # Boolean indicator determining if environment is inside a container
    #
    IS_CONTAINER=false

    # :
    # Name: isContainer
    # Purpose: Determines if the shell is executing inside a container environment
    #
    isContainer() {
        # ? Check mounted filesystems for container runtimes
        if command -v findmnt &>/dev/null; then
            if findmnt / | grep -qE 'overlay|containerd|docker'; then
                IS_CONTAINER=true
                return 0
            fi
        fi

        # ? Check filesystem inode on root directory (typically 2 on native filesystems)
        if [ "$(stat -c %i / 2>/dev/null)" != "2" ] && [ "$(stat -c %i / 2>/dev/null)" != "" ]; then
            IS_CONTAINER=true
            return 0
        fi

        # ? Check for presence of Docker environment indicator file
        if [ -f /.dockerenv ]; then
            IS_CONTAINER=true
            return 0
        fi

        # ? Inspect control groups for container markers
        if [ -f /proc/self/cgroup ] && grep -qi 'docker\|lxc\|kubepods\|containerd' /proc/self/cgroup; then
            IS_CONTAINER=true
            return 0
        fi

        IS_CONTAINER=false
        return 1
    }

    # $ Execute container check to update status variable
    isContainer

    # =
    # String representation of active container technology
    #
    CONTAINER_RUNTIME="unknown"

    # :
    # Name: CONTAINER_TYPE
    # Purpose: Identifies the specific type of container runtime engine in use
    #
    CONTAINER_TYPE() {
        if [ "$IS_CONTAINER" != true ]; then
            CONTAINER_RUNTIME="none (host/VM)"
            return 1
        fi

        # ? Evaluate environment variables for Podman
        if [ -n "$container" ] && [ "$container" = "podman" ]; then
            CONTAINER_RUNTIME="podman"
            return 0
        fi
        if grep -q "podman" /proc/self/environ 2>/dev/null; then
            CONTAINER_RUNTIME="podman"
            return 0
        fi

        # ? Check filesystem artifacts for Docker
        if [ -f /.dockerenv ] || [ -f /.dockerinit ]; then
            CONTAINER_RUNTIME="docker"
            return 0
        fi

        # ? Differentiate containerd vs Kubernetes
        if findmnt / 2>/dev/null | grep -q "containerd"; then
            if [ -d /var/run/secrets/kubernetes.io ] || [ -n "$KUBERNETES_SERVICE_HOST" ]; then
                CONTAINER_RUNTIME="kubernetes (containerd)"
            else
                CONTAINER_RUNTIME="containerd"
            fi
            return 0
        fi

        # ? Check process environment for LXC
        if [ -f /dev/lxc ] || grep -qa "lxc" /proc/1/environ 2>/dev/null; then
            CONTAINER_RUNTIME="lxc"
            return 0
        fi
        if [ -n "$container" ] && [ "$container" = "lxc" ]; then
            CONTAINER_RUNTIME="lxc"
            return 0
        fi

        # ? Check environment variable for systemd-nspawn
        if [ -n "$container" ] && [ "$container" = "systemd-nspawn" ]; then
            CONTAINER_RUNTIME="systemd-nspawn"
            return 0
        fi

        CONTAINER_RUNTIME="generic-container"
        return 0
    }

    # :
    # Name: detect_distro
    # Purpose: Parses os-release to determine the Linux distribution name and icon
    #
    detect_distro() {
        DISTRO_NAME="linux"

        if [[ -f /etc/os-release ]]; then
            # ? Source os-release in subshell to prevent variable contamination
            DISTRO_NAME=$(basename "$(sh -c '. /etc/os-release; echo ${ID:-linux}')")
        fi

        # = Fallback icon when Nerd Fonts are disabled
        local default_icon=$(icon_pick "" "🐧" "@")

        if [[ "$NERDFONT_ENABLED" == true ]]; then
            # ? Look up distro key in DISTRO_ICONS map, fallback to generic Linux icon
            DISTRO_ICON="${DISTRO_ICONS[$DISTRO_NAME]:-${DISTRO_ICONS[linux]}}"
        else
            DISTRO_ICON="$default_icon"
        fi
    }

    # ## Container Prompt Assembly
    if [[ "$IS_CONTAINER" == true ]]; then
        # $ Run runtime detection procedure
        CONTAINER_TYPE
        # $ Run distribution detection procedure
        detect_distro

        # ? Map container runtime to corresponding Nerd Font icon
        case "$CONTAINER_RUNTIME" in
            "kubernetes (containerd)") CONTAINER_ICON="" ;;
            "podman") CONTAINER_ICON="" ;;
            "docker") CONTAINER_ICON="" ;;
            *) CONTAINER_ICON="" ;;
        esac

        # = Define interactive container prompt format
        PROMPT="%F{magenta}${CONTAINER_ICON}%f %F{cyan}%n%f %F{cyan}${DISTRO_ICON} ${DISTRO_NAME}%f-%F{blue}%m%f %# "
        RPROMPT=""

        # ## Standard Host Shell Prompt Assembly
    else
        # = Store host kernel type
        KERN_TYPE=$(uname)

        if [[ "$KERN_TYPE" == "Darwin" ]]; then
            DISTRO_NAME="macos"
            DISTRO_ICON=$(icon_pick "" "🍏" "Mac")
        elif [[ "$KERN_TYPE" == "Linux" ]]; then
            # $ Detect Linux distro information
            detect_distro
        fi

        # = Define standard host prompt format
        PROMPT="%F{cyan}%n%f %F{cyan}${DISTRO_ICON} ${DISTRO_NAME}%f-%F{blue}%m%f %# "
        RPROMPT="$(date +%T)"
    fi

    # ## External Prompt Provider Loader
else if [[ -n "$PROMPT_PROVIDER" ]]; then
    # ? Source external prompt script if provider file exists
    [[ -f "$DOTFILES/prompt_providers/$PROMPT_PROVIDER" ]] && source "$DOTFILES/prompt_providers/$PROMPT_PROVIDER"
fi
