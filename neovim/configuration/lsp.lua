vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = true,
  }
)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require'cmp_nvim_lsp'.update_capabilities(capabilities)

local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  require'which-key'.register({
    D = {"<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration"},
    d = {"<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition"},
    t = {"<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to type definition"},
    r = {"<cmd>lua vim.lsp.buf.references()<cr>", "References"},
    R = {"<cmd>TroubleToggle lsp_references<cr>", "Trouble References"},
    i = {"<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation"},
  }, { prefix = "g", buffer = bufnr })

  -- Set some keybinds conditional on server capabilities
  local fmap = {}
  if client.resolved_capabilities.document_formatting then
    fmap = {"<cmd>lua vim.lsp.buf.formatting()<cr>", "Format buffer"}
  elseif client.resolved_capabilities.document_range_formatting then
    fmap = {"<cmd>lua vim.lsp.buf.range_formatting()<cr>", "Format range"}
  end

  require'which-key'.register({
    a = {"<cmd>lua vim.lsp.buf.code_action()<cr>", "Code actions"},
    n = {"<cmd>lua vim.lsp.buf.rename()<cr>", "Rename identifier"},
    d = {"<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", "Show diagnostics"},
    h = {"<cmd>lua vim.lsp.buf.hover()<cr>", "Show hover info"},
    s = {"<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature help"},
    k = {"<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", "Go to previous diagnostic"},
    j = {"<cmd>lua vim.lsp.diagnostic.goto_next()<cr>", "Go to next diagnostic"},
    l = {"<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Populate location list with diagnostics"},
    r = {"<cmd>lua vim.lsp.codelens.run()<cr>", "Run code lens"},
    f = fmap
  }, { prefix = "<leader>r", buffer = bufnr })

  vim.api.nvim_exec(
  [[
    hi! LspCodeLens gui=italic guifg=green
    autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
  ]], false)
end

local servers = {
  texlab = {},
  hls = {
    cmd = { "haskell-language-server", "--lsp" },
    root_dir = nvim_lsp.util.root_pattern('hie.yaml', '.git'),
  },
  rnix = {},
  pyright = {},
}

local function merge(t1, t2)
  for k,v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "tables") then
      merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end
local function prepare_opts(extra_opts)
  local def_opts = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150
    }
  }
  return merge(def_opts, extra_opts)
end

for lsp,extra_opts in pairs(servers) do
  nvim_lsp[lsp].setup(prepare_opts(extra_opts))
end

require'rust-tools'.setup{
  server = prepare_opts{},
}

require'trouble'.setup{
}
