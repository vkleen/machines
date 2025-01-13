return {
  "mrcjkb/rustaceanvim",
  dir = require("lazy-nix-helper").get_plugin_path("rustaceanvim"),
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      tools = {},
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              experimental = true,
            },
          },
        },
      },
      dap = {},
    }
  end,
}
