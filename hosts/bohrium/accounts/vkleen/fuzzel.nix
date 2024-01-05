{ pkgs, lib, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "PragmataPro Mono Liga:size=10";
        terminal = lib.getExe pkgs.foot;
      };
    };
  };
}
