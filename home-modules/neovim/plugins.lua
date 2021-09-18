g.fzf_layout = {
  window = {
    border = 'sharp',
    width = 0.9,
    height = 0.6,
  }
}
g.airline_extensions = {}
g.airline_powerline_fonts = false

require'colorizer'.setup()

require'gitsigns'.setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '┃', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  keymaps = {
    -- Default keymap options
    noremap = true,

    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},
  },
}

require'nvim-treesitter.configs'.setup {
  -- "all", "maintained" or a list
  -- Only use ones that are compiled by nix
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

require'telescope'.setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require'telescope.actions'.close
      }
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    lsp_handlers = {
      disable = {},
      location = {
        telescope = {},
        no_results_message = 'No references found',
      },
      symbol = {
        telescope = {},
        no_results_message = 'No symbols found',
      },
      call_hierarchy = {
        telescope = {},
        no_results_message = 'No calls found',
      },
      code_action = {
        telescope = require'telescope.themes'.get_dropdown(),
        no_results_message = 'No code actions available',
        prefix = '',
      },
    }
  }
}
require'telescope'.load_extension('fzf')
require'telescope'.load_extension('lsp_handlers')

require'telescope._extensions.zoxide.config'.setup{
  mappings = {
    default = {
      action = function(selection)
        vim.cmd('cd ' .. selection.path)
      end
    },
    ["<C-e>"] = {
      action = function(selection)
        require'telescope.builtin'.find_files({cwd = selection.path, initial_mode = 'insert'})
      end
    },
  }
}

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
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }
})

if vim.fn.executable('notify-send') then
  vim.notify = function(message, _, _)
    if type(message) ~= "string" then
      print(type(message))
      return
    end
    vim.fn.jobstart({"notify-send", "Neovim", message})
  end
else
  require'notify'.setup({
    stages = "static",
    timeout = 5000,
  })
  vim.notify = require'notify'
end

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
