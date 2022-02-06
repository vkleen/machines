local M = {}

function M.setup(capabilities, on_attach)
  require"rust-tools".setup{
    server = {
      capabilities = capabilities,
      on_attach = on_attach,
    },
  }
end

return M
