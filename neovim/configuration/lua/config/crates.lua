local M = {}

function M.setup()
  require'crates'.setup {
    text = {
      loading    = "   Loading",
      version    = "   %s",
      prerelease = "   %s",
      yanked     = "   %s",
      nomatch    = "   No match",
      upgrade    = "   %s",
      error      = "   Error fetching crate",
    },
    popup = {
      border = "rounded", -- same as nvim_open_win config.border
      text = {
        title      = "   %s ",
        version    = "    %s ",
        prerelease = "   %s ",
        yanked     = "   %s ",
        feature    = "    %s ",
        date       = " %s ",
      },
    },
  }
end

return M
