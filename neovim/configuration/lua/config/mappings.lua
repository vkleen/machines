local M = {}

local function register_multi_mode(modes, mappings)
  for _,m in pairs(modes) do
    require"which-key".register(mappings, {mode = m})
  end
end
M.register_multi_mode = register_multi_mode

local function WinMove(key)
  curwin = vim.api.nvim_win_get_number(0)
  local cmd = vim.cmd
  cmd(string.format("wincmd %s", key))
  if curwin == vim.api.nvim_win_get_number(0) then
    if key:find('[jk]') then
      cmd[[wincmd s]]
    else
      cmd[[wincmd v]]
    end
    cmd(string.format("wincmd %s", key))
  end
end

function M.setup()
  require"which-key".setup{
    marks = true,
    registers = true,
    spelling = { enabled = true },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    }
  }

  register_multi_mode({'n', 'v'}, {
    ['^'] = { 'q', 'Define a macro', noremap=true },
    ['q'] = { 'b', 'previous word' },
    ['Q'] = { 'B', 'previous WORD' },
  })

  require"which-key".register({
    ['<C-h>'] = { function() WinMove('h') end, 'Move to window on the left or create it' },
    ['<C-j>'] = { function() WinMove('j') end, 'Move to window below or create it' },
    ['<C-k>'] = { function() WinMove('k') end, 'Move to window above or create it' },
    ['<C-l>'] = { function() WinMove('l') end, 'Move to window on the right or create it' },

    ['<leader>o'] = { '<C-o>zz', 'Move back in jump list and center' },
    ['<leader>i'] = { '<C-i>zz', 'Move forward in jump list and center' },

    ['gh'] = { '0', 'Beginning of line' },
    ['gj'] = { 'G', 'End of buffer' },
    ['gk'] = { 'gg', 'Beginning of buffer' },
    ['gl'] = { '$', 'End of line' },

    ['J'] = { '3jzz', 'Move 3 lines down and center' },
    ['K'] = { '3kzz', 'Move 3 lines up and center' },

    [ '<M-j>' ] = { '<cmd>join<cr>', 'Join' },

    ['<leader>n'] = { '<cmd>nohl<cr>', 'Disable search highlight' },
  }, { mode = 'n' })

  require"which-key".register({
    ['jk'] = { '<ESC>', 'Escape' },
    ['<C-j>'] = { '<C-n>', 'Down' },
    ['<C-k>'] = { '<C-p>', 'Up' },
  }, { mode = 'i' })

  require"which-key".register({
    ['<C-u>'] = { '<C-\\><C-n>:q<cr>', 'Close terminal' },
  }, { mode = 't' })
end

return M
