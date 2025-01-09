return {
  {
    'Bilal2453/luvit-meta',
    dir = require('lazy-nix-helper').get_plugin_path('luvit-meta'),
    lazy = true,
  },
  {
    'folke/lazydev.nvim',
    dir = require('lazy-nix-helper').get_plugin_path('lazydev.nvim'),
    ft = 'lua',
    dependencies = {
      {
        'Bilal2453/luvit-meta',
        dir = require('lazy-nix-helper').get_plugin_path('luvit-meta'),
      }
    },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
}
