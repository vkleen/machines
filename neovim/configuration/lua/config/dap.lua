local M = {}

--TODO: mappings
function M.setup()
  require"dap".defaults.fallback.external_terminal = {
    command = 'alacritty',
    args = { '-e' },
  }

  require"dapui".setup{
  }
end

return  M
