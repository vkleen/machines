return {
  "stevearc/conform.nvim",
  dir = require("lazy-nix-helper").get_plugin_path("conform.nvim"),
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
    {
      "<leader>tf",
      function()
        vim.g.disable_autoformat = true
      end,
      mode = "n",
      desc = "[T]oggle [F]ormat on Save",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat then
        return
      end

      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = "never"
      else
        lsp_format_opt = "fallback"
      end

      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "nixpkgs_fmt", "injected" },
    },
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
    },
  },
}
