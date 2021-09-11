require'colorizer'.setup()

require'gitsigns'.setup {
  signs = {
    -- source: https://en.wikipedia.org/wiki/Box-drawing_character
    add          = {hl = 'GitSignsAdd'   , text = '┃', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
}

require'nvim-treesitter.configs'.setup {
  -- "all", "maintained" or a list
  ensure_installed = {
    "agda", "c", "javascript", "cpp", "rust", "lua", "python",
    "go", "bash", "json", "haskell", "yaml", "nix",
    "verilog", "regex", "comment", "latex"
  },
  highlight = { enable = true, },
  indent = { enable = false, },
  rainbow = {
    enable = true,
    extended_mode = true,
    -- prevents lagging in large files
    max_file_lines = 1000,
  },
}

require'treesitter-context'.setup{
  enable = true,
  throttle = true,
}

require'bufferline'.setup {
  options = {
    show_close_icon = false,
    show_buffer_close_icons = false,
    separator_style = "thick",
  },
}

require'lualine'.setup {
  options = {
    theme = "nord",
    -- disable powerline
    section_separators = '',
    component_separators = '',
  },
}

vim.o.guifont = "PragmataPro Mono Liga:h12"
vim.g["neovide_remember_window_size"] = false

require'telescope'.setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      }
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
require'telescope'.load_extension('fzf')

require('FTerm').setup({
  cmd = "zsh",
  -- border = { "┌", "─", "┐", "│", "┘", "─", "└", "└" },
  border = "rounded",
  dimensions = {
    height = 0.8,
    width = 0.8
  },
  auto_close = true
})
vim.api.nvim_set_keymap('n', '<leader>;', '<Cmd>lua require("FTerm").toggle()<CR>', { noremap = true, })

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end
  },
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n', true)
      elseif has_words_before() and vim.fn['vsnip#available']() == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '', true)
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function()
      if vim.fn.pumvisible() == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n', true)
      elseif vim.fn['vsnip#jumpable'](-1) == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-jump-prev)', true, true, true), '', true)
      end
    end, { 'i', 's' }),
  },
})
