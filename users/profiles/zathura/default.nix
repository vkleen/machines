{ config, pkgs, ... }:
{
 home.packages = [ pkgs.zathura ];
 xdg.configFile."zathura/zathurarc".text = ''
    set selection-clipboard clipboard
    set sandbox strict
    set continuous-hist-save true

    set default-bg "#103c48"
    set recolor-lightcolor "#103c48"
    set recolor-darkcolor "#adbcbc"
  '';

  programs.zsh.shellAliases = {
    llpp = "zathura";
  };
}
