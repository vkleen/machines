{ config, pkgs, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';

    virtualHosts = {
      "www.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        default = true;
        locations."/".return = "404";
      };
      "math.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/sites/math.kleen.org/";
        locations."= /favicon.ico".return = "204";
      };
      "beta.math.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/sites/beta.math.kleen.org";
        locations."= /favicon.ico".return = "204";
      };
    };
  };
}
