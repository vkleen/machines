{ ... }:
{
  programs.nixvim.plugins = {
    rustaceanvim = {
      enable = true;
      rustAnalyzerPackage = null;
    };
    crates-nvim.enable = true;
    nvim-cmp.sources = [ { name = "crates"; } ];
  };
}
