{ config, pkgs, lib, ... }:
let
  cfg = config.mailserver;

  blockedSpam = [
    "vkleen+wws.shop@17220103.de"
    "vkleen+gearbest@17220103.de"
    "vkleen-greeting@17220103.de"
    "vkleen+funimation@17220103.de"
    "vkleenfunimation@17220103.de"
    "funimation@17220103.de"
    "voelkner@17220103.de"
    "admin@17220103.de"
    "omega@17220103.de"
    "kleen@kleen.org"
    "admin@kleen.org"
  ];
in {
  mailserver = {
    enable = true;
    fqdn = "samarium.kleen.org";
    domains = [
      "samarium.17220103.de"
      "kleen.org"
      "17220103.de"
      "bouncy.email"
    ];
    virtualAliases = {
      "martin@kleen.org" = "martin.kleen@gmail.com";
      "tatjana@kleen.org" = "dr.kleen@t-online.de";
      "tatjana@samarium.kleen.org" = "dr.kleen@t-online.de";
      "some@bouncy.email" = "some@nights.email";
      "@samarium.17220103.de" = "vkleen";
      "@kleen.org" = "vkleen";
      "@17220103.de" = "vkleen";
      "@bouncy.email" = "vkleen";
    } // lib.genAttrs blockedSpam (_: "devnull");
    debug = false;
    messageSizeLimit = 0;
    mailboxSizeLimit = 0;
  };

  systemd.services.postfix = {
    after = [ "mailserver-certificates.target" ]
      ++ (lib.optional cfg.dkimSigning "opendkim.service");
    wants = [ "mailserver-certificates.target" ];
    requires = (lib.optional cfg.dkimSigning "opendkim.service");
  };

  systemd.targets."mailserver-certificates" = {
    wants = [ "acme-certificates.target" ];
    after = [ "acme-certificates.target" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."${cfg.fqdn}" = {
      serverName = cfg.fqdn;
      forceSSL = true;
      enableACME = true;
      http2 = false;
      acmeRoot = "/var/lib/acme/acme-challenge";
      locations."/".return = "404";
    };
  };

  security.acme = {
    acceptTerms = true;
    email = "vkleen-acme@17220103.de";
  };
}
