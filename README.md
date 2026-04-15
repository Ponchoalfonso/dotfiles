# Poncho's dotfiles :)
This is the configuration I try to bring to most of my systems

## Install

Make sure you have `zsh` and `git` installed, then run:

​```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Ponchoalfonso/dotfiles/main/scripts/install.zsh)"
​```

The script will:
- Install Oh My Zsh with plugins and Powerlevel10k
- Clone this repo as a bare git repository into `~/.dotfiles`
- Check out dotfiles into your home directory

### Manual install

If you prefer to set things up yourself:

​```bash
git clone --bare git@github.com:Ponchoalfonso/dotfiles.git $HOME/.dotfiles
alias dotf='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotf config status.showUntrackedFiles no
dotf checkout
​```

## Managing dotfiles

The repo uses a bare git setup. Use the `dotf` alias to interact with it:

​```bash
dotf status
dotf add ~/.config/oh-my-zsh/aliases.zsh
dotf commit -m "update aliases"
dotf push
​```
