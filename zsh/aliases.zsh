if command -v brew >/dev/null; then
  alias nano="$(brew --prefix)/bin/nano"
fi

alias zconf="$HOME/.dotfiles/zsh/tools/zshconfig"

alias z-refresh="source ~/.zshrc"

# ==========================================
# Automatically Generate CLI App Shortcuts
# ==========================================
# Define the directories to scan
local app_dirs=("/Applications" "$HOME/Applications")

for dir in $app_dirs; do
  # Check if directory exists to avoid errors
  if [ -d "$dir" ]; then
    # Loop through all .app bundles in the directory
    for app in "$dir"/*.app(N); do
      # Extract the app name (e.g., "Google Chrome")
      local app_name="${app:t:r}"

      # Create a lowercase, web-safe alias name (e.g., "google-chrome")
      # This removes spaces and replaces them with hyphens
      local alias_name="${app_name:l:gs/ /-}"

      # Only create the alias if the command name isn't already taken
      if ! launchable "$alias_name" >/dev/null 2>&1; then
        alias "$alias_name"="open -a \"$app_name\""
      fi
    done
  fi
done
