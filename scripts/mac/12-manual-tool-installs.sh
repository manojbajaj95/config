#!/bin/bash

set -euo pipefail

cat <<'EOF'
Manual tool installs
====================

These tools are intentionally not installed via Homebrew in this setup.

1. Cursor
   Download: https://cursor.com/en/downloads

2. Wispr Flow
   Download: https://wisprflow.ai/

3. Codex CLI
   Docs: https://help.openai.com/en/articles/11096431
   Install after Node is ready:
     npm install -g @openai/codex

4. Claude Code
   Docs: https://docs.anthropic.com/en/docs/claude-code/setup
   Install after Node is ready:
     npm install -g @anthropic-ai/claude-code

Suggested order:
  - Run ./scripts/mac/07-bootstrap-node.sh first
  - Install Cursor and Wispr Flow
  - Install Codex CLI and Claude Code
EOF
