local M = {}

function M.setup()
  vim.cmd[[autocmd WinEnter * if winnr('$') == 1 && &ft == 'Trouble' | q | endif]]

  require"trouble".setup{}
  require"which-key".register({
    x = { [[<cmd>TroubleToggle<cr>]], 'Open Trouble' },
    w = { [[<cmd>TroubleToggle workspace_diagnostics<cr>]], 'LSP Workspace diagnostics'},
    d = { [[<cmd>TroubleToggle document_diagnostics<cr>]], 'LSP Document diagnostics'},
    l = { [[<cmd>TroubleToggle loclist<cr>]], 'Location list'},
    q = { [[<cmd>TroubleToggle quickfix<cr>]], 'quickfix list'},
  }, { prefix = '<leader>x', mode = 'n' })
end

return M
