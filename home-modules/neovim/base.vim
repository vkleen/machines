let mapleader=' '
inoremap jk <ESC>
vnoremap u <ESC>
imap <C-j> <C-n>
imap <C-k> <C-p>

noremap <S-j> 3jzz
noremap <S-k> 3kzz

"splits
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr())
    if (match(a:key,'[jk]'))
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

noremap <silent> <C-h> :call WinMove('h')<CR>
noremap <silent> <C-j> :call WinMove('j')<CR>
noremap <silent> <C-k> :call WinMove('k')<CR>
noremap <silent> <C-l> :call WinMove('l')<CR>

"terminal
tnoremap <C-u> <C-\><C-n>:q<CR>

"true colors
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"vim update delay in ms
set updatetime=300

"disable mouse
set mouse=

"syntax
syntax enable
set number
set relativenumber
set autoread
set encoding=UTF-8

set clipboard=unnamedplus

"disable pre rendering of some things like ```
set conceallevel=0

set list
set showbreak=↪

set expandtab
set tabstop=2
set shiftwidth=2

set splitbelow
set splitright

set ignorecase
set smartcase

set hidden
set nobackup
set nowritebackup
set noswapfile
set noshowmode

noremap <leader>o <C-o>zz
noremap <leader>i <C-i>zz

au BufRead,BufNewFile *.nix set filetype=nix

set background=dark
colorscheme selenized
hi! link FloatBorder Normal
