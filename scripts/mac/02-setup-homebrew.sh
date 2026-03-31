#!/bin/bash

set -euo pipefail

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script must be run on macOS."
  exit 1
fi

brew_shellenv_line='eval "$(/opt/homebrew/bin/brew shellenv)"'
if [ "$(uname -m)" != "arm64" ]; then
  brew_shellenv_line='eval "$(/usr/local/bin/brew shellenv)"'
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

touch "$HOME/.zprofile"
if ! grep -Fq "$brew_shellenv_line" "$HOME/.zprofile"; then
  printf '\n%s\n' "$brew_shellenv_line" >> "$HOME/.zprofile"
  echo "Added Homebrew shellenv to ~/.zprofile"
fi

brew update
echo "Homebrew ready: $(brew --version | head -1)"
