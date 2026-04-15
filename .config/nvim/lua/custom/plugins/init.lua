-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.g.netrw_liststyle = 3
return {
  require 'custom.plugins.opencode',
  require 'custom.plugins.vim-tmux-navigator',
  require 'custom.plugins.netrw',
}
