return {
  "rachartier/tiny-inline-diagnostic.nvim",
  dir = require("lazy-nix-helper").get_plugin_path("tiny-inline-diagnostic.nvim"),
  event = { "VeryLazy" },
  priority = 1000,
  opts = {
    preset = "powerline",
    options = {
      multiple_diag_under_cursor = true,
    },
  },
}
