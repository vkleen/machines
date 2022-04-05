{ config, pkgs, ... }:
{
  services.chrony = {
    enable = true;
    extraConfig = ''
      allow
    '';
  };
}
