local M = {}

function M.setup()
  require"telescope".setup{
    defaults = {
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
      layout_strategy = "flex",
      mappings = {
        i = {
          ["<C-t>"] = require"trouble.providers.telescope".open_with_trouble,
          ["<C-h>"] = "which_key",
          ["<C-j>"] = require"telescope.actions".move_selection_next,
          ["<C-k>"] = require"telescope.actions".move_selection_previous,
        },
        n = { ["<C-t>"] = require"trouble.providers.telescope".open_with_trouble },
      },
    },
  }
  require"telescope".load_extension("fzf")
  require"telescope".load_extension('lsp_handlers')
  require"telescope".load_extension('dap')
  require"telescope._extensions.zoxide.config".setup{
    mappings = {
      default = {
        action = function(selection)
          vim.cmd('cd ' .. selection.path)
        end
      },
      ["<C-e>"] = {
        action = function(selection)
          require'telescope.builtin'.find_files({cwd = selection.path})
        end
      },
    }
  }
  require"which-key".register({
    f = { name = 'Telescope' }
  }, { prefix = '<leader>', mode = 'n' })
  require"which-key".register({
    f = { function() require"telescope.builtin".find_files() end, 'Find Files'},
    g = { function() require"telescope.builtin".live_grep() end, 'Live Grep'},
    b = { function() require"telescope.builtin".buffers() end, 'Buffers'},
    h = { function() require'telescope.builtin'.help_tags() end, 'Help'},
    z = { function() require"telescope".extensions.zoxide.list() end, 'Z'},
  }, { prefix = '<leader>f', mode = 'n' })

  vim.api.nvim_exec([[
    autocmd FileType TelescopePrompt lua require"cmp".setup.buffer { enabled = false }
  ]], false)
end

return M
