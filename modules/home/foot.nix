{ config, pkgs, ... }:
{
  programs.foot = {
    enable = true;
    server.enable = false;
    settings = {
      main = {
        term = "xterm-256color";
        font = "PragmataProLiga Nerd Font:size=7";
      };
      scrollback = {
        lines = 0;
      };
    };
  };
}
