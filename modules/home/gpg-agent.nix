{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry
    '';
  };
}
