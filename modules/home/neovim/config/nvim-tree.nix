{ ... }:
{
  programs.nixvim.plugins.nvim-tree = {
    enable = true;
    diagnostics = {
      enable = true;
      showOnDirs = true;
    };
    modified.enable = true;
  };
}
