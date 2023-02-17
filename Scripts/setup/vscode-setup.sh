#!/bin/bash

# Dump all code extensions with

# Install extensions via:
# code --install-extension $extension

# Manage setting json

# To backup
# mv ~/Library/Application\ Support/Code/User/settings.json ~/.vscode/
# mv ~/Library/Application\ Support/Code/User/keybindings.json ~/.vscode/
# mv ~/Library/Application\ Support/Code/User/snippets/ ~/.vscode/

# Create symlink
# ln -s $HOME/.vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
# ln -s $HOME/.vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json
# ln -s $HOME/.vscode/snippets/ $HOME/Library/Application\ Support/Code/User

# if not enough args displayed, display an error and die
[ $# -eq 0 ] && echo "Usage: $0 <backup/restore>" && exit 1

if [ "$1" == "backup" ];then
  code --list-extensions > $HOME/Scripts/code-extensions.lst
  mv ~/Library/Application\ Support/Code/User/settings.json ~/.vscode/
  mv ~/Library/Application\ Support/Code/User/keybindings.json ~/.vscode/
  mv ~/Library/Application\ Support/Code/User/snippets/ ~/.vscode/
  code --list-extensions > ~/.vscode/code-extensions.lst
elif [ "$1" == "restore" ];then
  # code --install-extension $extension
  ln -s $HOME/.vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
  ln -s $HOME/.vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json
  ln -s $HOME/.vscode/snippets/ $HOME/Library/Application\ Support/Code/User
else
  echo "Incorrect parameter"
fi

