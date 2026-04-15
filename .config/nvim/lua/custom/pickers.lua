pickers = {
  custom_find_files = function(opts, no_ignore, hidden)
    opts = opts or {}
    no_ignore = vim.F.if_nil(no_ignore, false)
    hidden = vim.F.if_nil(hidden, false)

    opts.attach_mappings = function(_, map)
      -- Toggle hidden files (Ctrl+H)
      map({ 'n', 'i' }, '<C-h>', function(prompt_bufnr)
        local prompt = require('telescope.actions.state').get_current_line()
        require('telescope.actions').close(prompt_bufnr)
        pickers.custom_find_files({ default_text = prompt }, no_ignore, not hidden)
      end)

      -- Toggle ignored files (Ctrl+I)
      map({ 'n', 'i' }, '<C-i>', function(prompt_bufnr)
        local prompt = require('telescope.actions.state').get_current_line()
        require('telescope.actions').close(prompt_bufnr)
        pickers.custom_find_files({ default_text = prompt }, not no_ignore, hidden)
      end)

      return true
    end

    -- Set title based on flag state
    if hidden and no_ignore then
      opts.prompt_title = 'Find Files <ALL>'
    elseif hidden then
      opts.prompt_title = 'Find Files <Allow Hidden>'
    elseif no_ignore then
      opts.prompt_title = 'Find Files <Allow Ignored>'
    else
      opts.prompt_title = 'Find Files'
    end

    opts.hidden = hidden
    opts.no_ignore = no_ignore

    require('telescope.builtin').find_files(opts)
  end,
}

return pickers
