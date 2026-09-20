#!/usr/bin/env zsh
emulate -L zsh
setopt errexit nounset pipefail

NVIM_BIN="${commands[nvim]:-nvim}"
PI_BIN="${commands[pi]:-pi}"
NVIM_CMD="${(q)NVIM_BIN}"
PI_CMD="${(q)PI_BIN}"

# Replace each command with an interactive shell when it exits so the tmux
# panes remain usable instead of disappearing.
SHELL_BIN="${SHELL:-${commands[zsh]:-/bin/sh}}"
SHELL_CMD="${(q)SHELL_BIN}"
KEEP_OPEN="; exec $SHELL_CMD -i"

if (( $# > 0 )); then
  NVIM_CMD+=" ${(j: :)${(q)argv}}"
fi
NVIM_CMD+="$KEEP_OPEN"
PI_CMD+="$KEEP_OPEN"

# Create Neovim on the left (70% width) and pi on the right (30%).
# Inside tmux: create a new window in the current session.
# Outside tmux: create a new tmux session and let tmux choose the session name.
if [[ -n "${TMUX:-}" ]]; then
  NVIM_PANE="$(tmux new-window -P -F '#{pane_id}' -n editor "$NVIM_CMD")"
  tmux split-window -h -t "$NVIM_PANE" -l 30% "$PI_CMD"
  tmux select-pane -t "$NVIM_PANE"
else
  TMUX_CREATED="$(tmux new-session -d -x "$(tput cols)" -y "$(tput lines)" -P -F '#{session_name} #{pane_id}' -n editor "$NVIM_CMD")"
  SESSION_NAME="${TMUX_CREATED%% *}"
  NVIM_PANE="${TMUX_CREATED#* }"
  tmux split-window -h -t "$NVIM_PANE" -l 30% "$PI_CMD"
  tmux select-pane -t "$NVIM_PANE"
  tmux attach-session -t "$SESSION_NAME"
fi
