return {
  'nvim-treesitter/nvim-treesitter',
  dir = require('lazy-nix-helper').get_plugin_path('nvim-treesitter'),
  event = "VeryLazy",
  lazy = vim.fn.argc(-1) == 0,

  init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,

  config = function(_, opts)
    vim.opt.runtimepath:prepend(require('lazy-nix-helper').get_plugin_path('nix-treesitter-grammars'))
    require('nvim-treesitter.configs').setup(opts)
  end,

  opts = {
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  },
}
