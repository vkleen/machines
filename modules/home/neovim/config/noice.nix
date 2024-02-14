{ ... }:
{
  programs.nixvim.plugins = {
    noice = {
      enable = true;
      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };
      presets = {
        bottom_search = true;
        inc_rename = false;
      };
    };
    notify.enable = true;
  };
}
