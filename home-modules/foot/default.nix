{ config, pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "PragmataPro Liga:size=6";
      };
      scrollback = {
        lines = 0;
      };
    };
  };
}
