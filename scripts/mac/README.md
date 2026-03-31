# macOS setup scripts

Run these manually, in order, as needed:

1. `./scripts/mac/01-install-xcode-cli-tools.sh`
2. `./scripts/mac/02-setup-homebrew.sh`
3. `./scripts/mac/03-install-brew-packages.sh`
4. `./scripts/mac/04-setup-shell-and-terminal.sh`
5. `./scripts/mac/05-setup-tmux.sh`
6. `./scripts/mac/06-install-fonts.sh`
7. `./scripts/mac/07-bootstrap-node.sh`
8. `./scripts/mac/08-bootstrap-python.sh`
9. `./scripts/mac/09-setup-github-auth.sh`
10. `./scripts/mac/10-start-colima.sh`
11. `./scripts/mac/11-backup-existing-dotfiles.sh`
12. Restore dotfiles as the final step:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare https://github.com/manojbajaj95/config.git $HOME/.cfg
config config --local status.showUntrackedFiles no
config checkout
```

Manual installs and non-scripted steps are documented in [MANUAL_SETUP.md](/Users/ankitaagarwal/Documents/Playground/manoj-config/scripts/mac/MANUAL_SETUP.md).

Notes:

- Software update checks are intentionally skipped.
- Cursor and Wispr Flow remain manual installs.
- Codex CLI and Claude Code remain manual follow-up from official docs.
- The backup script moves common conflicting files into `~/.dotfile-backups/<timestamp>/` before the final bare-repo checkout.
