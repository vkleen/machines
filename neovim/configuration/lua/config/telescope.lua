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
          require'telescope.builtin'.find_files({cwd = selection.path, initial_mode = 'insert'})
        end
      },
    }
  }
  require"which-key".register({
    name = 'Telescope',
    f = { function() require"telescope.builtin".find_files() end, 'Find Files'},
    g = { function() require"telescope.builtin".live_grep() end, 'Live Grep'},
    b = { function() require"telescope.builtin".buffers() end, 'Buffers'},
    h = { function() require'telescope.builtin'.help_tags() end, 'Help'},
    z = { function() require"telescope".extensions.zoxide.list() end, 'Z'},
  }, { prefix = '<leader>f', mode = 'n' })
end

return M
