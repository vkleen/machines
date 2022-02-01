local M = {}

function M.setup()
  require'lualine'.setup {
    options = {
      theme = "nord",
      -- disable powerline
      section_separators = '',
      component_separators = '',
    },
  }
end

return M
