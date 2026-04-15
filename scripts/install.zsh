#!/bin/zsh

set -e

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Install Oh My Zsh
echo "dotfiles.install ==> Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "dotfiles.install ==> Installing plugins and themes..."
ZSH_CUSTOM=$HOME/.config/oh-my-zsh
# Install Oh My Zsh plugins
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
# Install Oh My Zsh themes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Overwrite Oh My Zsh config in ~/.zshrc
echo "dotfiles.install ==> Configuring .zshrc..."
sedi 's|^# ZSH_CUSTOM=.*|ZSH_CUSTOM=$HOME/.config/oh-my-zsh|' ~/.zshrc
sedi 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
sedi 's|^plugins=.*|plugins=(git zsh-vi-mode fast-syntax-highlighting)|' ~/.zshrc


# Clone dotfiles
echo "dotfiles.install ==> Cloning dotfiles..."
git clone --bare https://github.com/Ponchoalfonso/dotfiles.git $HOME/.dotfiles

alias dotf='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

dotf config status.showUntrackedFiles no
dotf config core.sparseCheckout true

echo "/*" >> $HOME/.dotfiles/info/sparse-checkout
echo '!/README.md' >> $HOME/.dotfiles/info/sparse-checkout
echo '!/LICENSE' >> $HOME/.dotfiles/info/sparse-checkout

dotf checkout

echo "dotfiles.install ==> Done! Restart your shell."
