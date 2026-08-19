#!/bin/bash
## 00-path.bash

# Adds paths from pathrc to PATH, LD_LIBRARY_PATH, and MANPATH
# pathrc is a list of paths, one per line

# Ensure an absolute path is used so it works regardless of where the shell is launched
PATHRC_FILE="${DOTFILES:-$HOME/.dotfiles/bash}/pathrc"

if [[ -f "$PATHRC_FILE" ]]; then
  # The '|| [[ -n "$line" ]]' ensures the last line is read even if it lacks a newline character
  while IFS= read -r line || [[ -n "$line" ]]; do
    
    #? Remove leading and trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    #? Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    #? Expand tilde (~) to $HOME, as 'read' does not expand it automatically
    line="${line/#\~/$HOME}"

    if [[ -d "$line" ]]; then
      export PATH="$PATH:$line"
      
      #? Prevent leading colons if the variables are currently empty
      if [[ -z "${LD_LIBRARY_PATH:-}" ]]; then
        export LD_LIBRARY_PATH="$line"
      else
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$line"
      fi
      
      if [[ -z "${MANPATH:-}" ]]; then
        export MANPATH="$line"
      else
        export MANPATH="$MANPATH:$line"
      fi
    fi
  done < "$PATHRC_FILE"
fi