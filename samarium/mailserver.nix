{ config, pkgs, lib, ... }:
let
  cfg = config.mailserver;
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
      "samarium.kleen.org"
      "samarium.17220103.de"
      "kleen.org"
      "17220103.de"
    ];
    virtualAliases = {
      "tatjana@samarium.kleen.org" = "dr.kleen@t-online.de";
      "@samarium.17220103.de" = "vkleen";
      "@samarium.kleen.org" = "vkleen";
      "@kleen.org" = "vkleen";
      "@17220103.de" = "vkleen";
    };
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
