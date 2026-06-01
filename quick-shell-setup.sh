#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Quick Shell Setup starting..."

OS="$(uname -s)"

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
  echo "🍎 macOS detected"

  if ! have brew; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "📦 Installing core tools (brew)..."
  brew install git fzf ripgrep fd eza lazygit tmux btop zoxide
}

install_linux() {
  echo "🐧 Linux detected"

  if have apt; then
    sudo apt update

    sudo apt install -y \
      git fzf ripgrep tmux htop btop curl unzip wget

    # fd + eza fallback naming differences
    sudo apt install -y fd-find || true

  elif have pacman; then
    sudo pacman -S --noconfirm \
      git fzf ripgrep tmux htop btop curl unzip fd eza zoxide
  fi

  # zoxide install (universal fallback)
  if ! have zoxide; then
    echo "📦 Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  fi
}

echo "🔍 Detecting system..."

case "$OS" in
  Darwin) install_mac ;;
  Linux) install_linux ;;
  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

echo ""
echo "✨ Done installing base tools!"
echo ""
echo "👉 Next steps:"
echo "  • Restart your shell"
echo "  • Install a Nerd Font (JetBrainsMono recommended)"
echo "  • Add zoxide to shell:"
echo "      eval \"\$(zoxide init zsh)\""
echo ""
echo "🚀 You're ready."
