# Load dynamic aliases using the Python helper script
if command -v python3 >/dev/null 2>&1; then
  eval "$(python3 "$DOTFILES/scripts/load-aliases.py")"
fi
