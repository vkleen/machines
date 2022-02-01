local M = {}

function M.setup()
  local g = vim.g
  local opt = vim.opt

  g.neovide_floating_blur = false
  g.neovide_floating_opacity = 0.9
  g.neovide_remember_window_size = false
  opt.guifont = "PragmataPro Mono Liga:h12"
end

return M
