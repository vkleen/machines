local function bind(t)
  setmetatable(t, {__index = {opts = { silent = true, noremap = true }}})
  return { mode = t[1] or t.mode,
           keys = t[2] or t.keys,
           bind = t[3] or t.bind,
           opts = t[4] or t.opts
         }
end

local bindings = {
  bind{{'n', 'v'}, '^', 'q'},
  bind{{'n', 'v'}, 'q', 'b'},
  bind{{'n', 'v'}, 'Q', 'B'},


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

  bind{'n', 'gh', '0'},
  bind{'n', 'gl', '$'},
  bind{'n', 'gj', 'G'},
  bind{'n', 'gk', 'gg'},
}

function WinMove(key)
  curwin = vim.api.nvim_win_get_number(0)
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

require'which-key'.setup{
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = false },
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
}

require'which-key'.register({
  c = { name = 'commenter' },
  h = { name = 'Git' },

  b = {
    name = 'Buffers',
    d = {"<cmd>bdelete<cr>", "Delete Buffer"},
    c = {"<cmd>cd %:p:h<cr>", "Cd to buffer parent"},
  },

  f = {
    name = "Telescope",
    ["<leader>"] = {"<cmd>lua require'telescope'.extensions.frecency.frecency()<cr>", "Frecency"},
    f = {"<cmd>lua require'telescope.builtin'.find_files()<cr>", "Find Files"},
    g = {"<cmd>lua require'telescope.builtin'.live_grep()<cr>", "Live Grep"},
    G = {"<cmd>lua require'telescope'.extensions.ghq.list()<cr>", "GHQ"},
    b = {"<cmd>lua require'telescope.builtin'.buffers()<cr>", "Buffers"},
    h = {"<cmd>lua require'telescope.builtin'.help_tags()<cr>", "Help"},
    z = {"<cmd>lua require'telescope'.extensions.zoxide.list()<cr>", "Z"},
  },

  l = {
    name = 'linting / syntax',
    n = {"<cmd>noh<cr>", "Delete search highlights"},
  },
}, { prefix = "<leader>" })


do_bindings()
