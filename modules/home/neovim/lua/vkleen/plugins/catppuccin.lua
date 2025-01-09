return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    dir = require('lazy-nix-helper').get_plugin_path('catppuccin-nvim'),
    priority = 1000,
    init = function ()
      vim.cmd.colorscheme 'catppuccin'
    end,
    opts = {
      flavor = "mocha",
    },
  },
}
