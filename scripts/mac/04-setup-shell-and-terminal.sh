#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Oh My Zsh and shell plugins..."
"$REPO_ROOT/scripts/setup/zsh-setup.sh"

echo ""
echo "Next manual file migration suggestions:"
echo "  cp $REPO_ROOT/.zshrc ~/.zshrc"
echo "  cp $REPO_ROOT/.aliases ~/.aliases"
echo "  cp $REPO_ROOT/.p10k.zsh ~/.p10k.zsh"
echo "  mkdir -p ~/.config/ghostty && cp $REPO_ROOT/.config/ghostty/config ~/.config/ghostty/config"
