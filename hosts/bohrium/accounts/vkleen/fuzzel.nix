{ pkgs, lib, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "PragmataPro Mono Liga:size=8";
        terminal = lib.getExe pkgs.foot;
        width = 100;
        lines = 30;
      };
    };
  };
}
