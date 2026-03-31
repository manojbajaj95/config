#!/bin/bash

set -euo pipefail

BACKUP_ROOT="$HOME/.dotfile-backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

FILES_TO_BACKUP=(
  ".zshrc"
  ".zprofile"
  ".p10k.zsh"
  ".aliases"
  ".tmux.conf"
  ".tmux.conf.local"
  ".gitconfig"
  ".gitignore"
  ".config/ghostty/config"
)

mkdir -p "$BACKUP_DIR"

backed_up_any=false

for relative_path in "${FILES_TO_BACKUP[@]}"; do
  source_path="$HOME/$relative_path"
  if [ -e "$source_path" ] || [ -L "$source_path" ]; then
    destination_path="$BACKUP_DIR/$relative_path"
    mkdir -p "$(dirname "$destination_path")"
    mv "$source_path" "$destination_path"
    echo "Moved $source_path -> $destination_path"
    backed_up_any=true
  fi
done

if [ "$backed_up_any" = false ]; then
  echo "No known conflicting dotfiles were found."
  rmdir "$BACKUP_DIR" 2>/dev/null || true
  exit 0
fi

echo ""
echo "Backup complete: $BACKUP_DIR"
echo "You can now run the final bare-repo dotfiles restore."
