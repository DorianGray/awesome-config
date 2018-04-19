#!/bin/bash
if [ -z "$1" ]; then
  1=awesome
fi
if ! tmux has-session -t "$1" 2>&1 > /dev/null; then
  . ~/.profile
  tmux new -d -s "$1"
  tmux run-shell -b -t 0 "~/src/tmux-resurrect/scripts/restore.sh"
fi

exec tmux attach -t "$1"
