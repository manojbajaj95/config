```bash
: '
                                   _       _    __ _ _
                                  | |     | |  / _(_) |
                                __| | ___ | |_| |_ _| | ___  ___
                               / _` |/ _ \| __|  _| | |/ _ \/ __|
                              | (_| | (_) | |_| | | | |  __/\__ \
                               \__,_|\___/ \__|_| |_|_|\___||___/
                                --------------------------------
                           swiss army knife of any software engineer
                         ----------------------------------------------

             -----------------------------------------------------------------------
             This repository is the collection of configurations that I learned over
             time and tweaked for my personal taste. The repository contains configs
             files for vim, tmux, etc etc.  The reposiotry also contains scripts for
             automating the setup of your development machine.
             -----------------------------------------------------------------------
    
'
```

Please refer to instructions in the README if you want to replicate and tweak accordingly.

## Storing and Re-storing dotfiles

The dotfiles are stored in a git bare repository. There is no need to maintain symlinks, copy/paste, or complicated dotfile manager.
To replicate the setup, use the following commands:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare https://github.com/manojbajaj95/config.git $HOME/.cfg
config config --local status.showUntrackedFiles no
config checkout
```

You'll need to resolve conflicts if you already have any custom dotfiles.

Refer to [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)

## Initial Setup

### For Mac
Update your system to latest OS, then head over to App Store and install xcode.
Once completed, execute the following script:
```bash
~/Scripts/mac-first-time.sh
```
### For Arch:
TODO:

### For ubuntu:
TODO:

## Installing Pre-requisites/important Cli
TODO:


## Alacritty - terminal
TODO:

## Zsh - bash replacement
Execute:
```bash 
~/Scripts/zsh-setup.sh
```

## Vim -
Execute:

## Tmux 
Execute:

## Visual Studio Code
Execute:
```bash
~/Scriptsvscode-setup.sh restore
```

# Environment setup

## CPlusPlus

## Golang

## JavaScript/TypeScript

## Rust

## Python

