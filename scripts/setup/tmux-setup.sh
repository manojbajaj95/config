#!/bin/bash
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# tmux send-prefix -t 0 && tmux send-keys -t 0 "I"


# Backup existing tmux config
# mv $HOME/.tmux.conf $HOME/.tmux.conf.bkp
git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
ln -s -f $HOME/.tmux/.tmux.conf $HOME/.tmux.conf
# Skip following if it already exits
# cp $HOME/.tmux/.tmux.conf.local $HOME


