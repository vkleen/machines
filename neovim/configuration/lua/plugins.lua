vim.g.fzf_layout = {
  window = {
    border = 'sharp',
    width = 0.9,
    height = 0.6,
  }
}
vim.g.airline_extensions = {}
vim.g.airline_powerline_fonts = false

require'colorizer'.setup()

require 'nvim-web-devicons'.setup {
  default = true
}

require'lsp-colors'.setup{}

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
        ["<esc>"] = require'telescope.actions'.close,
        ["<c-t>"] = require'trouble.providers.telescope'.open_with_trouble
      },
      n = {
        ["<c-t>"] = require'trouble.providers.telescope'.open_with_trouble
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
require'telescope'.load_extension('dap')

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

local dap = require'dap'
dap.defaults.fallback.external_terminal = {
  command = 'alacritty',
  args = { '-e' },
}

require'dapui'.setup{}

vim.g.dap_virtual_text = true

require'crates'.setup {
    text = {
        loading    = "   Loading",
        version    = "   %s",
        prerelease = "   %s",
        yanked     = "   %s",
        nomatch    = "   No match",
        update     = "   %s",
        error      = "   Error fetching crate",
    },
    popup = {
        border = "rounded", -- same as nvim_open_win config.border
        text = {
            title      = "   %s ",
            version    = "    %s ",
            prerelease = "   %s ",
            yanked     = "   %s ",
            feature    = "    %s ",
            date       = " %s ",
        },
    },
}

local types = require("luasnip.util.types")
require'luasnip'.config.setup({
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = {{"●", "GruvboxOrange"}}
      }
    },
    [types.insertNode] = {
      active = {
        virt_text = {{"●", "GruvboxBlue"}}
      }
    }
  },
})

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm{
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      elseif require'luasnip'.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
      elseif require'luasnip'.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'crates' },
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

require"indent_blankline".setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
  use_treesitter = true,
}
