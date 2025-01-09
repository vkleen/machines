return {
  "NeogitOrg/neogit",
  dir = require("lazy-nix-helper").get_plugin_path("neogit"),
  dependencies = {
    {
      "nvim-lua/plenary.nvim",
      dir = require("lazy-nix-helper").get_plugin_path("plenary.nvim"),
    },
    {
      "sindrets/diffview.nvim",
      dir = require("lazy-nix-helper").get_plugin_path("diffview.nvim"),
    },
    {
      "ibhagwan/fzf-lua",
      dir = require("lazy-nix-helper").get_plugin_path("fzf-lua"),
    },
  },
  keys = {
    {
      "<leader>g",
      function()
        require("neogit").open()
      end,
      mode = "n",
      desc = "Open Neo[G]it",
    },
  },
  cmd = { "NeoGit" },
  lazy = true,
  opts = {},
}
