{ pkgs, lib, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = lib.getExe pkgs.foot;
        width = 100;
        lines = 30;
      };
    };
  };
}
