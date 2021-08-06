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


# Config
Please refer to instructions in the README if you want to replicate and tweak accordingly.

## Storing and Re-storing dotfiles

The dotfiles are stored in a git bare repository. There is no need to maintain symlinks, copy/paste, or complicated dotfile manager.
To replicate the setup, use the following commands:

```sh
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare <git-repo-url> $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
```

You'll need to resolve conflicts if you already have any custom dotfiles.

Refer to [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)

## Initial Setup

### For Mac
Update your system to latest OS, then head over to App Store and install xcode.
Once completed, execute the following script:
```sh
~/Scripts/mac-first-time.sh
```
### For Arch:
TODO:

### For ubuntu:
TODO:

## Installing Pre-requisites/important Cli
TODO:

## Installing Zsh
Execute:
```sh 
~/Scripts/zsh-setup.sh
```
