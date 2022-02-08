{ config, pkgs, lib, ... }:
{
  options = {
    zathura.pkg = lib.mkOption {
      default = (pkgs.zathuraPkgs.override { useMupdf = false; }).zathuraWrapper;
      type = lib.types.package;
    };
  };
  config = {
    home.packages = [ config.zathura.pkg ];
    xdg.configFile."zathura/zathurarc".text = ''
       set selection-clipboard clipboard
       set sandbox normal
       set continuous-hist-save true

       set default-bg "#103c48"
       set recolor-lightcolor "#103c48"
       set recolor-darkcolor "#adbcbc"
     '';

     programs.zsh.shellAliases = {
       llpp = "zathura";
     };
  };
}
