#!/bin/zsh

dotf() { git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@" }

NVIM_PATH=$HOME/.config/nvim
cd $NVIM_PATH
NVIM_MSG=$(git log -1 --pretty=%s)

echo "dotfiles.nvim ==> Updating nvim submodule reference in dotfiles..."
dotf add $HOME/.config/nvim
dotf commit -m "$NVIM_MSG"
dotf push
echo "dotfiles.nvim ==> Done!"
