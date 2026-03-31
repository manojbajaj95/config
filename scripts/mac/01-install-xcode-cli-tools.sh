#!/bin/bash

set -euo pipefail

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script must be run on macOS."
  exit 1
fi

if xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools already installed at: $(xcode-select -p)"
  exit 0
fi

echo "Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || true

echo "Finish the GUI install, then rerun this script if needed."
