#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up tmux configuration..."
"$REPO_ROOT/scripts/setup/tmux-setup.sh"

echo ""
echo "If needed, also copy your local tmux config:"
echo "  cp $REPO_ROOT/.tmux.conf.local ~/.tmux.conf.local"
