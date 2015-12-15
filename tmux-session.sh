#!/bin/sh
if tmux has-session -t "$1"; then
  exec tmux attach -t "$1"
else
  . ~/.profile
  exec tmux new -s "$1"
fi
