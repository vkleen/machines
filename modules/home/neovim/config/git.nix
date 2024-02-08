{ ... }:
{
  programs.nixvim.plugins = {
    gitsigns = {
      enable = true;
    };
    fugitive.enable = true;
  };
}
