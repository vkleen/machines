return {
  "LeonHeidelbach/trailblazer.nvim",
  dir = require("lazy-nix-helper").get_plugin_path("trailblazer.nvim"),
  opts = {
    mappings = {
      nv = {
        motions = {
          peek_move_next_down = "<A-j>",
          peek_move_previous_up = "<A-k>",
        },
      },
    },
  },
}
