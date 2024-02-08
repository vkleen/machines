{ ... }:
{
  programs.nixvim.plugins.nvim-cmp = {
    enable = true;
    mapping = {
      "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })";
      "<C-p>" = "cmp.mapping.select_prev_item()";
      "<C-n>" = "cmp.mapping.select_next_item()";
      "<C-u>" = "cmp.mapping.scroll_docs(-4)";
      "<C-d>" = "cmp.mapping.scroll_docs(4)";
    };
    sources = [
      { name = "nvim_lsp"; }
      { name = "dap"; }
      { name = "emoji"; }
      { name = "path"; }
      { name = "buffer"; }
    ];
  };
}
