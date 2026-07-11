#!/bin/zsh

set -e

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

prepend_file() {
  local content=$1 file=$2 temp
  temp=$(mktemp "${file}.XXXXXX")
  {
    print -r -- "$content"
    cat "$file"
  } > "$temp"
  mv "$temp" "$file"
}

append_file() {
  print -r -- "$1" >> "$2"
}

clone_if_missing() {
  local repository=$1 destination=$2 depth=$3

  if [[ -e "$destination" ]]; then
    if [[ -d "$destination/.git" ]]; then
      echo "dotfiles.install ==> $destination already exists; skipping."
      return
    fi

    echo "dotfiles.install ==> $destination exists but is not a Git repository." >&2
    return 1
  fi

  if [[ -n "$depth" ]]; then
    git clone --depth="$depth" "$repository" "$destination"
  else
    git clone "$repository" "$destination"
  fi
}

INSTANT_PROMPT='# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'

P10K_SOURCE='# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'


# Install Oh My Zsh
ZSH_DIR="$HOME/.oh-my-zsh"
echo "dotfiles.install ==> Installing Oh My Zsh..."
if [[ -e "$ZSH_DIR" ]]; then
  if [[ ! -d "$ZSH_DIR" ]]; then
    echo "dotfiles.install ==> $ZSH_DIR exists but is not a directory." >&2
    exit 1
  fi
  echo "dotfiles.install ==> Oh My Zsh already exists; skipping."
else
  ZSH="$ZSH_DIR" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "dotfiles.install ==> Installing plugins and themes..."
ZSH_CUSTOM="$HOME/.config/oh-my-zsh"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"
# Install Oh My Zsh plugins
clone_if_missing https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
clone_if_missing https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
# Install Oh My Zsh themes
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" 1

# Overwrite Oh My Zsh config in ~/.zshrc
echo "dotfiles.install ==> Configuring .zshrc..."
if [[ ! -f "$HOME/.zshrc" ]]; then
  touch "$HOME/.zshrc"
fi
if ! grep -Fqx -- '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.' "$HOME/.zshrc"; then
  prepend_file "$INSTANT_PROMPT" "$HOME/.zshrc"
fi
sedi 's|^# ZSH_CUSTOM=.*|ZSH_CUSTOM=$HOME/.config/oh-my-zsh|' "$HOME/.zshrc"
sedi 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
sedi 's|^plugins=.*|plugins=(git zsh-vi-mode fast-syntax-highlighting)|' "$HOME/.zshrc"
if ! grep -Fqx -- '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' "$HOME/.zshrc"; then
  append_file "$P10K_SOURCE" "$HOME/.zshrc"
fi

# Clone dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
echo "dotfiles.install ==> Cloning dotfiles..."
if [[ -e "$DOTFILES_DIR" ]]; then
  if [[ "$(git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository 2>/dev/null)" != "true" ]]; then
    echo "dotfiles.install ==> $DOTFILES_DIR exists but is not a bare Git repository." >&2
    exit 1
  fi
  echo "dotfiles.install ==> Dotfiles repository already exists; skipping clone."
else
  git clone --bare https://github.com/Ponchoalfonso/dotfiles.git "$DOTFILES_DIR"
fi

alias dotf='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

dotf config status.showUntrackedFiles no
dotf config core.sparseCheckout true

cat > "$DOTFILES_DIR/info/sparse-checkout" <<'EOF'
/*
!/README.md
!/LICENSE
EOF

dotf checkout

dotf submodule update --init --recursive

echo "dotfiles.install ==> Done! Restart your shell."
