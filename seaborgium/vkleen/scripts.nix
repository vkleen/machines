{ pkgs, ... }:
let update-chlorine-boot = pkgs.writeScriptBin "update-chlorine-boot" ''
      #!${pkgs.stdenv.shell}
      ssh -t chlorine -- update-boot
      scp root@chlorine:/boot/\* $HOME/machines/chlorine/boot/
    '';
in {
  home.packages = [
    update-chlorine-boot
  ];
}
