#!/usr/bin/zsh
#PATH="$PATH:/usr/local/opt/ccache/libexec"

# Adds paths from pathsrc to PATH, LD_LIBRARY_PATH, and MANPATH
# pathrc is a list of paths, one per line
if [[ -f "pathrc" ]]; then
  while IFS= read -r line; do
    if [[ -d "$line" ]]; then
      PATH="$PATH:$line"
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$line"
      MANPATH="$MANPATH:$line"
    fi
  done < "pathrc"
fi