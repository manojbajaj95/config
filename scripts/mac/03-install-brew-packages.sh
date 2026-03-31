#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script must be run on macOS."
  exit 1
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Run 02-setup-homebrew.sh first."
  exit 1
fi

echo "Installing Brew packages from $BREWFILE"
brew bundle --file="$BREWFILE"
brew doctor || true
