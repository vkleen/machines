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
    fqdn = "neodymium.kleen.org";
    domains = [
      "neodymium.17220103.de"
      "samarium.17220103.de"
      "kleen.org"
      "17220103.de"
      "as210286.net"
      "zorn-encryption.org"
    ];
    virtualAliases = {
      "martin@kleen.org" = "martin.kleen@gmail.com";
      "tatjana@kleen.org" = "dr.kleen@t-online.de";
      "tatjana@samarium.kleen.org" = "dr.kleen@t-online.de";
      "@samarium.17220103.de" = "vkleen";
      "@neodymium.17220103.de" = "vkleen";
      "@kleen.org" = "vkleen";
      "@17220103.de" = "vkleen";
      "@as210286.net" = "vkleen";
      "@zorn-encryption.org" = "vkleen";
    } // lib.genAttrs blockedSpam (_: "devnull");
    debug = false;
    messageSizeLimit = 0;
    mailboxSizeLimit = 0;
  };

  services.postfix = {
    extraAliases = ''
      vklee: vkleen
      devnull: /dev/null
    '';
    extraConfig = lib.mkBefore ''
      inet_interfaces = 127.0.0.1,202.61.250.130,[::1],[2a03:4000:54:9b1::25]
    '';
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

  security.acme.domains.${cfg.fqdn} = {};
}
