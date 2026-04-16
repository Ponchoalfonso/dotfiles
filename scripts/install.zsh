#!/bin/zsh

set -e

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
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
sedi '1i\'"$INSTANT_PROMPT"'' ~/.zshrc
sedi 's|^# ZSH_CUSTOM=.*|ZSH_CUSTOM=$HOME/.config/oh-my-zsh|' ~/.zshrc
sedi 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
sedi 's|^plugins=.*|plugins=(git zsh-vi-mode fast-syntax-highlighting)|' ~/.zshrc
sedi '$a\'"$P10K_SOURCE"'' ~/.zshrc

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

dotf submodule update --init --recursive

echo "dotfiles.install ==> Setting up nvim post-push hook..."
mkdir -p $HOME/.config/nvim/.git/hooks
cp $HOME/scripts/nvim-post-push.zsh $HOME/.config/nvim/.git/hooks/post-push
chmod +x $HOME/.config/nvim/.git/hooks/post-push

echo "dotfiles.install ==> Done! Restart your shell."
