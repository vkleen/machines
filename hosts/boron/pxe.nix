{ config, pkgs, lib, ... }:
{
  networking.firewall.interfaces."auenheim" = {
    allowedTCPPorts = [ 80 ];
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts."boron.auenheim.kleen.org" = {
      listen = lib.mkForce [
        { addr = "10.172.100.1"; port = 80; }
        { addr = "[2a06:e881:9008::1]"; port = 80; }
      ];
      forceSSL = lib.mkForce false;
      locations = {
        "/".return = "404";
        "/chlorine/" = {
          extraConfig = ''
            rewrite ^/chlorine/(.*) /$1 break;
          '';
          root = "/srv/tftp/chlorine/";
        };
      };
    };
  };
}
