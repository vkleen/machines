{pkgs, ...}:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry
    '';
  };
}
