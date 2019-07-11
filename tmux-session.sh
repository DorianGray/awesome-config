#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

TMUX=/usr/bin/tmux
TMUX_CONF="${HOME}/.config/tmux"
TMUX_ARGS="-f${TMUX_CONF}/.tmux.conf"
TMUX_PLUGINS="${TMUX_CONF}/plugins"

TMUX_SESSION="${1:-awesome}"

if ! (${TMUX} ${TMUX_ARGS} has-session -t "${TMUX_SESSION}" 2> /dev/null); then
  ${TMUX} ${TMUX_ARGS} new -d -s "${TMUX_SESSION}"
  sleep 0.1
  ${TMUX} ${TMUX_ARGS} run-shell -b -t "$TMUX_SESSION" "${TMUX_PLUGINS}/tmux-resurrect/scripts/restore.sh"
fi

exec ${TMUX} ${TMUX_ARGS} attach -t "${TMUX_SESSION}"
