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
  local cmd=vim.cmd
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
    d = {[[<cmd>bdelete<cr>]], "Delete Buffer"},
    c = {[[<cmd>cd %:p:h<cr>]], "Cd to buffer parent"},
  },

  f = {
    name = "Telescope",
    ["<leader>"] = {[[<cmd>lua require'telescope'.extensions.frecency.frecency()<cr>]], "Frecency"},
    f = {[[<cmd>lua require'telescope.builtin'.find_files()<cr>]], "Find Files"},
    g = {[[<cmd>lua require'telescope.builtin'.live_grep()<cr>]], "Live Grep"},
    G = {[[<cmd>lua require'telescope'.extensions.ghq.list()<cr>]], "GHQ"},
    b = {[[<cmd>lua require'telescope.builtin'.buffers()<cr>]], "Buffers"},
    h = {[[<cmd>lua require'telescope.builtin'.help_tags()<cr>]], "Help"},
    z = {[[<cmd>lua require'telescope'.extensions.zoxide.list()<cr>]], "Z"},
  },

  l = {
    name = 'linting / syntax',
    n = {[[<cmd>noh<cr>]], "Delete search highlights"},
  },

  x = {
    name = 'Trouble',
    n = {
      x = {[[<cmd>TroubleToggle<cr>]], "Open Trouble"},
      w = {[[<cmd>TroubleToggle lsp_workspace_diagnostics<cr>]], "LSP Workspace diagnostics"},
      d = {[[<cmd>TroubleToggle lsp_document_diagnostics<cr>]], "LSP Document diagnostics"},
      l = {[[<cmd>TroubleToggle loclist<cr>]], "Location list"},
      q = {[[<cmd>TroubleToggle quickfix<cr>]], "quickfix list"},
    }
  },

  [';'] = { [[<cmd>luad require'FTerm'.toggle()<cr>]], "Toggle terminal" },
}, { prefix = "<leader>" })

require'which-key'.register({
  s = { [[<cmd>lua require'gitsigns'.stage_hunk()<cr>]], 'Stage hunk' },
  u = { [[<cmd>lua require'gitsigns'.undo_stage_hunk()<cr>]], 'Unstage hunk' },
  r = { [[<cmd>lua require'gitsigns'.reset_hunk()<cr>]], 'Reset hunk' },
  R = { [[<cmd>lua require'gitsigns'.reset_buffer()<cr>]], 'Reset buffer' },
  p = { [[<cmd>lua require'gitsigns'.preview_hunk()<cr>]], 'Preview hunk' },
  b = { [[<cmd>lua require'gitsigns'.blame_line(true)<cr>]], 'Blame line' },
  S = { [[<cmd>lua require'gitsigns'.stage_buffer()<cr>]], 'Stage buffer' },
  U = { [[<cmd>lua require'gitsigns'.reset_buffer_index()<cr>]], 'Reset buffer index' },
}, { prefix = "<leader>h" })
require'which-key'.register({
  s = { [[<cmd>lua require'gitsigns'.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}<cr>]], 'Stage hunk' },
  r = { [[<cmd>lua require'gitsigns'.reset_hunk({vim.fn.line('.'), vim.fn.line('v')})<cr>]], 'Reset hunk' },
}, { prefix = "<leader>h", mode = 'v' })
require'which-key'.register({
  h = { [[<cmd>lua require'gitsigns.actions'.select_hunk()<cr>]], 'Select hunk' },
}, { prefix = "i", mode = 'o' })
require'which-key'.register({
  h = { [[<cmd>lua require'gitsigns.actions'.select_hunk()<cr>]], 'Select hunk' },
}, { prefix = "i", mode = 'x' })

do_bindings()

function do_cargo_toml_bindings()
  if vim.fn.expand('%:t') ~= 'Cargo.toml' then
    return
  end
  local which_key = require'which-key'
  which_key.register({
    v = {
      name = 'Cargo crates',
      t = {[[<cmd>lua require'crates'.toggle()<cr>]], "Toggle version display"},
      r = {[[<cmd>lua require'crates'.reload()<cr>]], "Reload versions"},
      u = {[[<cmd>lua require'crates'.update_crate()<cr>]], "Update to newest compatible version"},
      a = {[[<cmd>lua require'crates'.update_all_crates()<cr>]], "Update all to newest compatible version"},
      U = {[[<cmd>lua require'crates'.upgrade_crate()<cr>]], "Upgrade to newest version"},
      A = {[[<cmd>lua require'crates'.upgrade_all_crates()<cr>]], "Upgrade all to newest version"},
      h = {[[<cmd>lua require'crates'.show_popup()<cr>]], "Show crates popup"},
    },
  }, { prefix = "<leader>" })

  which_key.register({
    v = {
      name = 'Cargo crates',
      u = {[[<cmd>lua require'crates'.update_crates()<cr>]], "Update to newest compatible version"},
      U = {[[<cmd>lua require'crates'.upgrade_crates<cr>]], "Upgrade to newest version"},
    },
  }, { prefix = "<leader>", mode = "v" })
end
vim.cmd[[autocmd FileType toml lua do_cargo_toml_bindings()]]
