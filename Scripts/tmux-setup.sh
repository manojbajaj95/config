#!/bin/bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux send-prefix -t 0 && tmux send-keys -t 0 "I"

