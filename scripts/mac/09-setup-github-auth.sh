#!/bin/bash

set -euo pipefail

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

mkdir -p "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  ssh-keygen -t ed25519 -C "manojbajaj95@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  pbcopy < "$HOME/.ssh/id_ed25519.pub"
  echo "Public key copied to clipboard. Add it to GitHub, then continue."
else
  echo "Existing SSH public key found at ~/.ssh/id_ed25519.pub"
fi

if command -v gh >/dev/null 2>&1; then
  echo "Run 'gh auth login' when ready."
else
  echo "gh is not installed. Run 03-install-brew-packages.sh first."
fi
