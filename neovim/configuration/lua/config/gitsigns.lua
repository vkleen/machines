local M = {}

function M.setup()
  require"gitsigns".setup {
    signs = {
      add          = {hl = 'GitSignsAdd'   , text = '┃', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
      change       = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
      delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      changedelete = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
  }

  require"which-key".register({
    s = { function() require"gitsigns".stage_hunk() end, 'Stage hunk' },
    u = { function() require"gitsigns".undo_stage_hunk() end, 'Unstage hunk' },
    r = { function() require"gitsigns".reset_hunk() end, 'Reset hunk' },
    R = { function() require"gitsigns".reset_buffer() end, 'Reset buffer' },
    p = { function() require"gitsigns".preview_hunk() end, 'Preview hunk' },
    b = { function() require"gitsigns".blame_line(true) end, 'Blame line' },
    S = { function() require"gitsigns".stage_buffer() end, 'Stage buffer' },
    U = { function() require"gitsigns".reset_buffer_index() end, 'Reset buffer index' },
  }, { prefix = '<leader>h' })
  require"which-key".register({
    s = { function() require"gitsigns".stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, 'Stage hunk' },
    r = { function() require"gitsigns".reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, 'Reset hunk' },
  }, { prefix = '<leader>h', mode = 'v' })
  require"which-key".register({
    h = { function() require"gitsigns.actions".select_hunk() end, 'Select hunk' },
  }, { prefix = 'i', mode = 'o' })
  require"which-key".register({
    h = { function() require"gitsigns.actions".select_hunk() end, 'Select hunk' },
  }, { prefix = 'i', mode = 'x' })
end

return M
