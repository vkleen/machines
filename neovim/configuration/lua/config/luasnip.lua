local M = {}

function M.setup()
  require"luasnip".config.set_config{
    history = true,
    region_check_events = 'CursorHold',
    delete_check_events = 'TextChanged',
  }
  require"luasnip.loaders.from_vscode".load()
end

return M
