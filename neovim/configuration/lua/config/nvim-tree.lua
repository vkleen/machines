local M = {}

function M.setup()
  vim.g.nvim_tree_indent_markers = 1

  require"nvim-tree".setup{
    update_focused_file = {
      enable = true
    },
    view = {
      mappings = {
        list = {
          { key = 'l', action = 'edit' },
          { key = 'h', action = 'close_node' },
          { key = 'r', action = 'full_rename' },
          { key = 'm', action = 'cut' },
          { key = 'd', action = 'remove' },
          { key = 'y', action = 'copy' },
          { key = { '<C-g>', '<C-c>', 'q' }, action = "close", action_cb = function(node)
            require"nvim-tree".close()
            vim.cmd('AerialClose')
          end },
        },
      },
    },
  }

  require"which-key".register({
    ['<C-e>'] = { function()
      require"nvim-tree".close()
      vim.cmd("AerialClose")
      require"nvim-tree".find_file(true)
    end, 'Open file explorer sidebar' },
  }, { mode = 'n' })
end

return M
