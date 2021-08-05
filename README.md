# Config
The repository contains dotfiles for personal setup. They have been tweaked over the years for my personal use and tast.
Please refer to instructions in the README if you want to replicate and tweak accordingly.

## How to store dotfiles

The dotfiles are stored in a git bare repository. There is no need to maintain symlinks, copy/paste, or complicated dotfile manager.
To replicate the setup, use the following commands:

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare <git-repo-url> $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout

You'll need to resolve conflicts if you already have any custom dotfiles.

Refer to The best way to store your dotfiles: A bare Git repository - https://www.atlassian.com/git/tutorials/dotfiles

## Initial Setup

### For Mac
Update your system to latest OS, then head over to App Store and install xcode.
Once completed, execute the following script:
~/Scripts/mac-first-time.sh

### For Arch:
TODO:

### For ubuntu:
TODO:

## Installing Pre-requisites/important Cli
TODO:

## Installing Zsh
Execute 
~/Scripts/zsh-setup.sh

