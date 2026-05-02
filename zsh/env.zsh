setopt CORRECT

export PATH="$PATH:$HOME/.local/bin"

# Container detection (Distrobox-safe)
if [[ -n "$CONTAINER_ID" ]]; then
  export IS_CONTAINER=1
fi
