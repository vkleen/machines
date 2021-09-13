let g:which_key_map = {}
call which_key#register('<Space>', 'g:which_key_map')

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :WhichKeyVisual '<Space>'<CR>
let g:which_key_map['c'] = { 'name': 'commenter' }

set timeoutlen=500
set signcolumn=yes

nmap <leader>ln :noh<CR>

let g:which_key_map['l'] = { 'name': 'linting / syntax' }

"better wildmenu
set wildmenu
set wildmode=longest:list,full

let g:fzf_layout = { 'window': { 'border': 'sharp', 'width': 0.9, 'height': 0.6 } }

"let g:which_key_map['e'] = { 'name': 'exec' }

let g:airline_extensions = []
let g:airline_powerline_fonts = 0

nnoremap <silent> ^ q
nnoremap <silent> <a-^> Q
nnoremap <silent> q b
nnoremap <silent> Q B
nnoremap <silent> <a-q> <a-b>
nnoremap <silent> <a-Q> <a-B>
vnoremap <silent> ^ q
vnoremap <silent> <a-^> Q
vnoremap <silent> q b
vnoremap <silent> Q B
vnoremap <silent> <a-q> <a-b>
vnoremap <silent> <a-Q> <a-B>

let g:which_key_map['f'] = { 'name': 'Telescope' }
nnoremap <silent> ; <cmd>lua require'telescope.builtin'.find_files()<cr>
nnoremap <silent> <leader>ff <cmd>lua require'telescope.builtin'.find_files()<cr>
nnoremap <silent> <leader><leader> <cmd>lua require'telescope'.extensions.frecency.frecency()<cr>
nnoremap <silent> <leader>fg <cmd>lua require'telescope.builtin'.live_grep()<cr>
nnoremap <silent> <leader>fG <cmd>lua require'telescope'.extensions.ghq.list()<cr>
nnoremap <silent> <leader>fb <cmd>lua require'telescope.builtin'.buffers()<cr>
nnoremap <silent> <leader>fh <cmd>lua require'telescope.builtin'.help_tags()<cr>

let g:which_key_map['h'] = { 'name': 'Git' }
let g:which_key_map['b'] = { 'name': 'Buffers' }
nnoremap <silent> <leader>bd <cmd>bdelete<cr>

let $GIT_EDITOR = 'nvr -cc split --remote-wait'
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
