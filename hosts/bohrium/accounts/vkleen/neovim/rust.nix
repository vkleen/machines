{ ... }:
{
  programs.nixvim.plugins = {
    rustaceanvim = {
      enable = true;
      rustAnalyzerPackage = null;
    };
    crates-nvim.enable = true;
    cmp.settings.sources = [{ name = "crates"; }];
  };
}
