local M = {}

function M.setup()
  require"nvim-treesitter.configs".setup{
    ensure_installed = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      --TODO mappings
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
    },
  }

  require"treesitter-context".setup{
    enable = true,
    throttle = true,
  }

  require"indent_blankline".setup{
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
    use_treesitter = true,
  }
end

return M
