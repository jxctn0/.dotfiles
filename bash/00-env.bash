#!/bin/bash
## 00-env.bash

setopt CORRECT

export PATH="$PATH:$HOME/.local/bin:$HOME/.dotfiles/tools"

# Container detection (Distrobox-safe)
if [[ -n "$CONTAINER_ID" ]]; then
  export IS_CONTAINER=1
fi
