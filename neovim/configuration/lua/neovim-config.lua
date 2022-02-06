local M = {}

function M.setup()
  local cmd = vim.cmd
  local exec = vim.api.nvim_exec
  local fn = vim.fn
  local g = vim.g
  local opt = vim.opt

  g.mapleader = ' '
  opt.mouse = ''
  opt.clipboard = 'unnamedplus'
  opt.swapfile = false

  opt.syntax = 'enable'
  opt.number = true
  opt.relativenumber = true
  opt.autoread = true
  opt.encoding = 'UTF-8'

  opt.conceallevel = 0
  opt.list = true
  opt.listchars:append("space:⋅")
  opt.showbreak = '↪'

  opt.expandtab = true
  opt.tabstop = 2
  opt.shiftwidth = 2

  opt.splitbelow = true
  opt.splitright = true

  opt.ignorecase = true
  opt.smartcase = true

  opt.hidden = true
  opt.backup = false
  opt.writebackup = false
  opt.swapfile = false
  opt.showmode = false

  opt.updatetime = 300
  opt.timeoutlen = 500
  opt.signcolumn = 'yes'

  opt.termguicolors = true
  vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = '1'

  opt.wildmenu = true
  opt.wildmode = 'longest:list,full'

  opt.background = 'dark'

  vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait'
  cmd[[autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete]]

  require"config.colors".setup{}
  require"config.neovide".setup{}
  require"config.nvim-notify".setup{}
  require"config.gitsigns".setup{}
  require"config.cmp".setup{}
  require"config.luasnip".setup{}
  require"config.lsp".setup{}
  require"config.dap".setup{}
  require"colorizer".setup{}
  require"config.treesitter".setup{}
  require"config.trouble".setup{}
  require"config.nvim-tree".setup{}
  require"config.crates".setup{}
  require"config.telescope".setup{}
  require"config.lualine".setup{}

  require"numb".setup{}
  require"lsp-colors".setup{}
  require"hlslens".setup{}

  require"config.mappings".setup{}
end

return M
