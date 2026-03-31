#!/bin/bash

set -euo pipefail

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v fnm >/dev/null 2>&1; then
  echo "fnm is not installed. Run 03-install-brew-packages.sh first."
  exit 1
fi

eval "$(fnm env --shell bash)"

fnm install --lts
fnm default lts-latest
fnm use lts-latest

if command -v pnpm >/dev/null 2>&1; then
  pnpm setup || true
fi

echo "Node.js bootstrap complete."
