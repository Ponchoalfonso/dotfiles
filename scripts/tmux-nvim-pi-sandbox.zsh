#!/usr/bin/env zsh
emulate -L zsh
setopt errexit nounset pipefail

SCRIPT_DIR="${0:A:h}"
PI_SANDBOX="$SCRIPT_DIR/pi-sandbox.py"
NVIM_BIN="${commands[nvim]:-nvim}"
NVIM_CMD="${(q)NVIM_BIN}"
PI_SANDBOX_CMD="${(q)PI_SANDBOX}"

if (( $# > 0 )); then
  NVIM_CMD+=" ${(j: :)${(q)argv}}"
fi

# Create Neovim on the left (75% width) and pi-sandbox on the right (25%).
# Inside tmux: create a new window in the current session.
# Outside tmux: create a new tmux session and let tmux choose the session name.
if [[ -n "${TMUX:-}" ]]; then
  NVIM_PANE="$(tmux new-window -P -F '#{pane_id}' -n editor "$NVIM_CMD")"
  tmux split-window -h -t "$NVIM_PANE" -l 30% "$PI_SANDBOX_CMD"
  tmux select-pane -t "$NVIM_PANE"
else
  TMUX_CREATED="$(tmux new-session -d -x "$(tput cols)" -y "$(tput lines)" -P -F '#{session_name} #{pane_id}' -n editor "$NVIM_CMD")"
  SESSION_NAME="${TMUX_CREATED%% *}"
  NVIM_PANE="${TMUX_CREATED#* }"
  tmux split-window -h -t "$NVIM_PANE" -l 30% "$PI_SANDBOX_CMD"
  tmux select-pane -t "$NVIM_PANE"
  tmux attach-session -t "$SESSION_NAME"
fi
