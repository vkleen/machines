return {
  "neovim/nvim-lspconfig",
  dir = require("lazy-nix-helper").get_plugin_path("nvim-lspconfig"),
  dependencies = {
    {
      "j-hui/fidget.nvim",
      dir = require("lazy-nix-helper").get_plugin_path("fidget.nvim"),
      opts = {},
    },
    {
      "saghen/blink.cmp",
      dir = require("lazy-nix-helper").get_plugin_path("blink-cmp"),
    },
  },
  event = { "VimEnter" },
  opts = {
    servers = require("vkleen.lsp.servers"),
  },
  config = function(_, opts)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("vkleen-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", function() require("fzf-lua").lsp_definitions() end, "[G]oto [D]efinition")
        map("gr", function() require("fzf-lua").lsp_references() end, "[G]oto [R]eferences")
        map("gI", function() require("fzf-lua").lsp_implementations() end, "[G]oto [I]mplementations")
        map("<leader>D", function() require("fzf-lua").lsp_typedefs() end, "Type [D]efinition")
        map("<leader>ds", function() require("fzf-lua").lsp_document_symbols() end, "[D]ocument [S]ymbols")
        map("<leader>ws", function() require("fzf-lua").lsp_live_workspace_symbols() end, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", function() require("fzf-lua").lsp_code_actions({silent = true}) end, "[C]ode [A]ction", { "n", "x" })
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        map("<leader>td", function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled(), { bufnr = event.buf })
        end, "[T]oggle [D]iagnostics")

        vim.diagnostic.config({ virtual_text = false })

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup("vkleen-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("vkleen-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "vkleen-lsp-highlight", buffer = event2.buf })
            end,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled, { bufnr = event.buf })
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    local lspconfig = require("lspconfig")
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
  end,
}
