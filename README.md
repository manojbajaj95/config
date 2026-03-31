```bash
: '
                                   _       _    __ _ _
                                  | |     | |  / _(_) |
                                __| | ___ | |_| |_ _| | ___  ___
                               / _` |/ _ \| __|  _| | |/ _ \/ __|
                              | (_| | (_) | |_| | | | | |  __/\__ \
                               \__,_|\___/ \__|_| |_|_|\___||___/
                                --------------------------------
                           swiss army knife of any software engineer
                         ----------------------------------------------
'
```

This repository contains personal dotfiles plus helper scripts for Linux and macOS.

## Scope

The current macOS path is optimized for a work machine with:

- Ghostty
- zsh + Oh My Zsh + Powerlevel10k
- Chrome
- Raycast
- Cursor installed manually
- Wispr Flow installed manually
- Python via `uv`
- Node via `fnm`
- `pnpm` instead of npm where practical
- GitHub CLI and SSH keys

Linux configs remain in the repo and are not part of the macOS bootstrap flow.

## Dotfiles storage

The dotfiles are stored in a git bare repository:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare https://github.com/manojbajaj95/config.git $HOME/.cfg
config config --local status.showUntrackedFiles no
config checkout
```

Resolve conflicts before checking out over any existing files.

Reference: [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)

## macOS setup

Install Xcode Command Line Tools first:

```bash
xcode-select --install
```

Then run:

```bash
./scripts/mac/01-install-xcode-cli-tools.sh
./scripts/mac/02-setup-homebrew.sh
./scripts/mac/03-install-brew-packages.sh
./scripts/mac/04-setup-shell-and-terminal.sh
./scripts/mac/05-setup-tmux.sh
./scripts/mac/06-install-fonts.sh
./scripts/mac/07-bootstrap-node.sh
./scripts/mac/08-bootstrap-python.sh
./scripts/mac/09-setup-github-auth.sh
./scripts/mac/10-start-colima.sh
./scripts/mac/11-backup-existing-dotfiles.sh
./scripts/mac/12-manual-tool-installs.sh
```

The numbered macOS flow is documented in [scripts/mac/README.md](/Users/ankitaagarwal/Documents/Playground/manoj-config/scripts/mac/README.md). Manual installs and account-specific steps are documented in [scripts/mac/MANUAL_SETUP.md](/Users/ankitaagarwal/Documents/Playground/manoj-config/scripts/mac/MANUAL_SETUP.md).

As the final step, restore the dotfiles with the bare repository flow:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare https://github.com/manojbajaj95/config.git $HOME/.cfg
config config --local status.showUntrackedFiles no
config checkout
```

The backup script above moves common conflicting files into `~/.dotfile-backups/<timestamp>/` before `config checkout`.

## Environment setup

### Python

Check `~/.env.d/python.env`

```bash
create_venv
venv
```

### JavaScript / TypeScript

Check `~/.env.d/node.env`

```bash
fnm install --lts
fnm default lts-latest
pnpm setup
```

### Go

Check `~/.env.d/go.env` if needed.

## Notes

- `SpaceVim` is no longer part of the setup flow.
- `yabai` and `skhd` are intentionally not installed on macOS.
- VS Code restore is no longer part of the default setup flow.
- No Ollama or local-model tooling is included.
