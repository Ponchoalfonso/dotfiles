#!/bin/zsh

dotf() { git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@" }

NVIM_MSG=$(git log -1 --pretty=%s)

echo "dotfiles.nvim ==> Updating nvim submodule reference in dotfiles..."
dotf submodule update --remote .config/nvim
dotf add .config/nvim
dotf commit -m "nvim: $NVIM_MSG"
dotf push
echo "dotfiles.nvim ==> Done!"
