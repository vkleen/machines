local function bind(t)
  setmetatable(t, {__index = {opts = { silent = true, noremap = true }}})
  return { mode = t[1] or t.mode,
           keys = t[2] or t.keys,
           bind = t[3] or t.bind,
           opts = t[4] or t.opts
         }
end

local bindings = {
  bind{'n', '<leader>', ":WhichKey '<Space>'<CR>"},
  bind{'v', '<leader>', ":WhichKeyVisual '<Space>'<CR>"},

  bind{'n', '<leader>ln', ':noh<cr>'},

  bind{{'n', 'v'}, '^', 'q'},
  bind{{'n', 'v'}, 'q', 'b'},
  bind{{'n', 'v'}, 'Q', 'B'},

  bind{'n', ';', "<cmd>lua require'telescope.builtin'.find_files()<cr>"},
  bind{'n', '<leader>ff', "<cmd>lua require'telescope.builtin'.find_files()<cr>"},
  bind{'n', '<leader><leader>', "<cmd>lua require'telescope'.extensions.frecency.frecency()<cr>"},
  bind{'n', '<leader>fg', "<cmd>lua require'telescope.builtin'.live_grep()<cr>"},
  bind{'n', '<leader>fG', "<cmd>lua require'telescope'.extensions.ghq.list()<cr>"},
  bind{'n', '<leader>fb', "<cmd>lua require'telescope.builtin'.buffers()<cr>"},
  bind{'n', '<leader>fh', "<cmd>lua require'telescope.builtin'.help_tags()<cr>"},

  bind{'n', '<leader>bd', "<cmd>bdelete<cr>"},

  bind{'i', 'jk', '<ESC>'},
  bind{'i', '<C-j>', '<C-n>', {}},
  bind{'i', '<C-k>', '<C-p>', {}},

  bind{'n', '<S-j>', '3jzz'},
  bind{'n', '<S-k>', '3kzz'},

  bind{'n', '<C-h>', ':lua WinMove("h")<cr>'},
  bind{'n', '<C-j>', ':lua WinMove("j")<cr>'},
  bind{'n', '<C-k>', ':lua WinMove("k")<cr>'},
  bind{'n', '<C-l>', ':lua WinMove("l")<cr>'},

  bind{'t', '<C-u>', '<C-\\><C-n>:q<cr>'},

  bind{'n', '<leader>o', '<C-o>zz'},
  bind{'n', '<leader>i', '<C-i>zz'},
}

function WinMove(key)
  curwin = vim.api.nvim_win_get_number(0)
  cmd(string.format("wincmd %s", key))
  if curwin == vim.api.nvim_win_get_number(0) then
    if key:find('[jk]') then
      cmd[[wincmd v]]
    else
      cmd[[wincmd s]]
    end
    cmd(string.format("wincmd %s", key))
  end
end

local function do_bindings()
  for _,b in ipairs(bindings) do
    modes = b.mode
    if type(modes) == 'string' then
      modes = { b.mode }
    end

    for _,m in ipairs(modes) do
      vim.api.nvim_set_keymap(m, b.keys, b.bind, b.opts)
    end
  end
end

g.which_key_map = {
  c = { name = 'commenter' },
  l = { name = 'linting / syntax' },
  f = { name = 'Telescope' },
  h = { name = 'Git' },
  b = { name = 'Buffers' },
}
fn['which_key#register']('<Space>', 'g:which_key_map')

do_bindings()
