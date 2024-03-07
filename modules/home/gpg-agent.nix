{ pkgs, lib, ... }:
let
  pinentry = pkgs.writeShellScript "pinentry" ''
    PATH=$PATH:${lib.getBin pkgs.coreutils}/bin:${lib.getBin pkgs.rofi}/bin
    exec "${lib.getExe' pkgs.pinentry-rofi "pinentry-rofi"}" "$@"
  '';
in
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    enableExtraSocket = true;
    enableScDaemon = false;
    extraConfig = ''
      pinentry-program ${pinentry}
    '';
  };
}
