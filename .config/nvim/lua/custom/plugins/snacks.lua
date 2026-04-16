return {
  'folke/snacks.nvim',
  lazy = false,
  opts = {
    input = {}, -- Enhances `ask()`
    picker = { -- Enhances `select()`
      actions = {
        opencode_send = function(...) return require('opencode').snacks_picker_send(...) end,
      },
      win = {
        input = {
          keys = {
            ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
          },
        },
      },
    },
  },
}
