return {
  'saghen/blink.cmp',
  dir = require('lazy-nix-helper').get_plugin_path('blink-cmp'),
  event = 'VimEnter',
  dependencies = {
    {
      'echanovski/mini.nvim',
      dir = require('lazy-nix-helper').get_plugin_path('mini.nvim'),
    },
  },
  opts = {
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    keymap = {
      preset = 'enter',
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = {
      prebuilt_binaries = {
        ignore_version_mismatch = true,
      },
    },

    completion = {
      ghost_text = { enabled = true },
      list = {
        selection = {
          preselect = false,
        },
      },
      documentation = {
        auto_show = true,
      },
      menu = {
        draw = {
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              -- Optionally, you may also use the highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            }
          }
        }
      }
    },

    signature = { enabled = true },
  },
  opts_extend = {
    'sources.default'
  },
}
