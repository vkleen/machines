{ ... }:
{
  programs.nixvim.plugins.cmp = {
    enable = true;
    settings = {
      mapping = {
        "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-u>" = "cmp.mapping.scroll_docs(-4)";
        "<C-d>" = "cmp.mapping.scroll_docs(4)";
      };
      expand = "function(args) require('luasnip').lsp_expand(args.body) end";
      sources = [
        { name = "nvim_lsp"; }
        { name = "nvim_lsp_document_symbol"; }
        { name = "nvim_lsp_signature_help"; }
        { name = "dap"; }
        { name = "emoji"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
    };
  };
}
