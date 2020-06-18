{ config, pkgs, lib, ... }:
let
  cfg = config.mailserver;

  blockedSpam = [
    "vkleen+wws.shop@17220103.de"
    "vkleen+gearbest@17220103.de"
    "vkleen-greeting@17220103.de"
    "funimation@17220103.de"
    "voelkner@17220103.de"
    "kleen@kleen.org"
    "admin@kleen.org"
  ];
in {
  imports = [
    ./mailserver/options.nix
    ./mailserver/opendkim.nix
    ./mailserver/postfix.nix
    ./acme.nix
  ];

  mailserver = {
    enable = true;
    fqdn = "samarium.kleen.org";
    domains = [
      "samarium.17220103.de"
      "kleen.org"
      "17220103.de"
    ];
    virtualAliases = {
      "tatjana@kleen.org" = "dr.kleen@t-online.de";
      "tatjana@samarium.kleen.org" = "dr.kleen@t-online.de";
      "@samarium.17220103.de" = "vkleen";
      "@kleen.org" = "vkleen";
      "@17220103.de" = "vkleen";
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
}
