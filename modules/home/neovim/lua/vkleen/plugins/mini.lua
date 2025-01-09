return {
  "echanovski/mini.nvim",
  dir = require("lazy-nix-helper").get_plugin_path("mini.nvim"),
  event = { "VimEnter" },
  config = function()
    require("mini.icons").setup({})
    MiniIcons.mock_nvim_web_devicons()

    require("mini.ai").setup({ n_lines = 500 })

    require("mini.surround").setup()

    require("mini.pairs").setup()

    local statusline = require("mini.statusline")
    statusline.setup({ use_icons = vim.g.have_nerd_font })
    statusline.section_location = function()
      return "%2l:%-2v"
    end
  end,
}
