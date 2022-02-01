local M = {}

local function generate_sources(null_ls)
  local sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.stylua,
  }
  return sources
end

function M.setup(_, on_attach)
  local null_ls = require"null-ls"

  null_ls.setup{
    on_attach = on_attach,
    sources = generate_sources(null_ls),
  }
end

return M
