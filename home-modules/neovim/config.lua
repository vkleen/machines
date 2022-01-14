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

cmd[[au BufRead,BufNewFile *.nix set filetype=nix]]

vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait'
cmd[[autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete]]

g.neovide_floating_blur = false
g.neovide_floating_opacity = 0.9
g.neovide_remember_window_size = false
opt.guifont = "PragmataPro Mono Liga:h12"
--opt.guifont = "PragmataProMonoLiga Nerd Font:h12"
