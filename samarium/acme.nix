{config, pkgs, lib, ...}:
let
  cfg = config.mailserver;
  acmeRoot = "/var/lib/acme/acme-challenge";

  preliminarySelfsigned = config.security.acme.preliminarySelfsigned;

  acmeWantsTarget = [ "acme-certificates.target" ]
    ++ (lib.optional preliminarySelfsigned "acme-selfsigned-certificates.target");
  acmeAfterTarget = if preliminarySelfsigned
    then [ "acme-selfsigned-certificates.target" ]
    else [ "acme-certificates.target" ];
in {
  systemd.targets."mailserver-certificates" = {
    wants = acmeWantsTarget;
    after = acmeAfterTarget;
  };

  services.nginx = {
    enable = true;
    virtualHosts."${cfg.fqdn}" = {
      serverName = cfg.fqdn;
      forceSSL = true;
      enableACME = true;
      http2 = false;
      acmeRoot = acmeRoot;
    };
  };

  security.acme.certs."${cfg.fqdn}".postRun = ''
      systemctl reload nginx
      systemctl reload postfix
    '';
}
