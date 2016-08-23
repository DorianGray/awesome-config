#!/bin/sh
if ! tmux has-session -t "$1"; then
  . ~/.profile
  tmux new -d -s "$1"
  tmux run-shell -b -t 0 "~/src/tmux-resurrect/scripts/restore.sh"
fi

exec tmux attach -t "$1"
