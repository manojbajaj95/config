# Manual macOS setup

This document covers the parts of the work-machine setup that are intentionally manual or account-specific.

You can also print the same checklist with:

```bash
./scripts/mac/12-manual-tool-installs.sh
```

## Already handled by Brew

The macOS Brewfile installs:

- Ghostty
- Raycast
- `git`, `gh`
- `uv`
- `fnm`
- `pnpm`
- `colima`
- Docker CLI tooling
- core CLI tools like `fd`, `fzf`, `ripgrep`, `jq`, `tmux`, `neovim`

## Install manually

### Cursor

Download the macOS ARM build from [cursor.com](https://cursor.com/en/downloads).

### Wispr Flow

Install from [wisprflow.ai](https://wisprflow.ai/).

## AI CLIs

These move quickly enough that it is better to follow the official install docs:

- Codex CLI: [OpenAI help article](https://help.openai.com/en/articles/11096431)
- Claude Code: [Anthropic setup docs](https://docs.anthropic.com/en/docs/claude-code/setup)

At the time of writing, the documented install commands are:

```bash
npm install -g @openai/codex
npm install -g @anthropic-ai/claude-code
```

Inference from the official docs: both tools currently expect a working Node.js installation first, so run the `fnm` setup below before installing them.

## Node.js bootstrap

After Brew installs `fnm` and `pnpm`, run:

```bash
fnm install --lts
fnm default lts-latest
fnm use lts-latest
pnpm setup
```

Then restart your shell.

## Python bootstrap

`uv` is installed by Brew. Typical first use:

```bash
uv python install
uv tool update-shell
```

## Fonts

Install the bundled fonts from this repo:

```bash
~/scripts/mac/install-fonts.sh ~/Assets/fonts
```

## GitHub authentication and SSH

Check whether a key already exists:

```bash
ls ~/.ssh
```

If there is no suitable GitHub key, generate a fresh one for this Mac:

```bash
ssh-keygen -t ed25519 -C "manojbajaj95@gmail.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

Then:

1. Add the copied public key to GitHub.
2. Authenticate GitHub CLI:

```bash
gh auth login
```

## Colima

Start the container runtime only when you need it:

```bash
colima start
docker version
```

No Ollama or local-model tooling is included in this setup.
