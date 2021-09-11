nvim_lsp["hls"].setup {
  cmd = { "haskell-language-server", "--lsp" },
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150
  }
}
