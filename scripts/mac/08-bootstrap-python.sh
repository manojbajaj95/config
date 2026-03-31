#!/bin/bash

set -euo pipefail

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is not installed. Run 03-install-brew-packages.sh first."
  exit 1
fi

uv python install
uv tool update-shell || true

echo "Python bootstrap complete."
