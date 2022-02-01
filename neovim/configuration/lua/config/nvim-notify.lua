local M = {}

function M.setup()
  require"notify".setup{
    stages = "fade_in_slide_out",
    render = "minimal"
  }
  vim.notify = require"notify"
end

return M
