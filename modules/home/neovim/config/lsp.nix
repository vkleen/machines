{ ... }:
{
  programs.nixvim.plugins = {
    lsp = {
      enable = true;
    };
    fidget = {
      enable = true;
      progress = {
        pollRate = 0.5;
        ignoreDoneAlready = true;
      };
    };
  };
}
