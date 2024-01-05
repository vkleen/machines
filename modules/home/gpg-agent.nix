{ pkgs, lib, ... }:
let
  pinentry = pkgs.writeShellScript "pinentry" ''
    PATH=$PATH:${lib.getBin pkgs.coreutils}/bin:${lib.getBin pkgs.rofi}/bin
    exec "${lib.getExe' pkgs.pinentry-rofi "pinentry-rofi"}" "$@"
  '';
in
{
  home.packages = [
    pkgs.rofi
  ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    extraConfig = ''
      pinentry-program ${pinentry}
    '';
  };
}
