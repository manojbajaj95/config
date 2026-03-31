#!/bin/bash

set -euo pipefail

mkdir -p "$HOME/.config/nvim"

cat <<'EOF'
SpaceVim has been removed from this setup.

Neovim is installed via Homebrew in the macOS Brewfile.
If you want editor config, add your own files under:
  ~/.config/nvim
EOF
