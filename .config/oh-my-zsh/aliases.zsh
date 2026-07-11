alias dotf='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias pi-prune='$HOME/scripts/pi-prune.py'

alias pi-sandbox='$HOME/scripts/pi-sandbox.py'
alias nvim='$HOME/scripts/tmux-nvim-pi-sandbox.zsh'

# Give only the tmux pane running SSH a Catppuccin Mocha appearance.
# Pane-local tmux styles avoid changing the entire Ghostty window.
_tmux_ssh_theme_on() {
  [[ -n ${TMUX_PANE:-} ]] || return
  command tmux set-option -p -t "$TMUX_PANE" window-style 'fg=#cdd6f4,bg=#1e1e2e'
  command tmux set-option -p -t "$TMUX_PANE" window-active-style 'fg=#cdd6f4,bg=#1e1e2e'
}

_tmux_ssh_theme_off() {
  [[ -n ${TMUX_PANE:-} ]] || return
  command tmux set-option -p -u -t "$TMUX_PANE" window-style
  command tmux set-option -p -u -t "$TMUX_PANE" window-active-style
}

ssh() {
  _tmux_ssh_theme_on
  {
    command ssh "$@"
  } always {
    # zsh runs this for normal exits, failures, and interrupts.
    _tmux_ssh_theme_off
  }
}
