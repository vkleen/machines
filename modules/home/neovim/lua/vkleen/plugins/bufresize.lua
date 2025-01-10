return {
  "kwkarlwang/bufresize.nvim",
  dir = require("lazy-nix-helper").get_plugin_path("bufresize.nvim"),
  event = { "VimResized", "BufWinEnter", "WinEnter" },
  opts = {},
}
