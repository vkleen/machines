{ flake, config, hostName, pkgs, lib, ... }:
let
  inherit (flake.inputs.utils.lib) getPublicV6 getPublicV4 lists strings;

  reverseDomain = domain: strings.concatStringsSep "." (lists.reverseList (strings.splitString "." domain));
  indentString = indentation: str:
    strings.concatMapStringsSep "\n" (str: "  ${str}")
      (strings.splitString "\n" (strings.removeSuffix "\n" str));

  acmeChallengeZonefile = domain: pkgs.writeText "${reverseDomain "_acme-challenge.${domain}"}.soa" ''
    $ORIGIN _acme-challenge.${domain}.
    $TTL 3600
    @ IN SOA ns.as210286.net. root.as210286.net. 2022080101 10800 3600 604800 30

      IN NS  ns.as210286.net.
  '';

  knotKeys = let
    dir = ./keys;
    toKeyInfo = name: v:
      if (v == "regular" || v == "symlink") && strings.hasSuffix ".age" name
      then { path = dir + "/${name}"; name = strings.removeSuffix ".age" name; }
      else null;
  in lib.filter (v: v != null) (lib.mapAttrsToList toKeyInfo (builtins.readDir dir));

  mkZone = {domain, path ? (./zones + "/${reverseDomain domain}.soa"), acmeDomains ? [domain], addACLs ? {}}:
    indentString "  " (let
      keys = acmeDomain: [(assert (config.age.secrets ? "dns/${acmeDomain}_acme"); "${acmeDomain}_acme_acl")]
                         ++ (addACLs.${acmeDomain} or []);
    in ''
      - domain: ${domain}
        template: inwx_zone
        ${lib.optionalString (acmeDomains != []) "acl: [local_acl, inwx_acl]"}
        file: ${path}
      ${strings.concatMapStringsSep "\n" (acmeDomain: ''
        - domain: _acme-challenge.${acmeDomain}
          template: acme_zone
          acl: [${strings.concatStringsSep ", " (keys acmeDomain)}]
          file: ${acmeChallengeZonefile acmeDomain}
      '') acmeDomains}
    '');

    toAcmeACL = { name, ... }:
      if lib.hasSuffix "_acme" name
      then
        indentString "  " ''
          - id: ${name}_acl
            key: ${name}_key
            action: update
        ''
      else null;
in {
  networking.firewall.allowedTCPPorts = [ 53 ];
  services.knot = {
    enable = true;
    keyFiles = map ({name, ...}: "/run/agenix/dns/${name}") knotKeys;
    extraConfig = ''
      server:
        listen: 127.0.0.1@53
        listen: ::1@53
        listen: ${lists.head (getPublicV4 flake hostName)}@53
        listen: ${lists.head (getPublicV6 flake hostName)}@53

      remote:
        - id: inwx_notify
          address: 2a0a:c980::53
          via: ${lists.head (getPublicV6 flake hostName)}
        - id: recursive
          address: ::1@5353
        - id: local
          address: ::1@53
          key: knot_local_key

      acl:
        - id: inwx_acl
          address: [185.181.104.96, 2a0a:c980::53]
          action: transfer
        - id: local_acl
          key: knot_local_key
          action: update
          update-type: DS
      ${lib.concatStringsSep "\n" (lib.filter (v: v != null) (builtins.map toAcmeACL knotKeys))}

      mod-rrl:
        - id: default
          rate-limit: 200
          slip: 2

      mod-cookies:
        - id: default
          secret-lifetime: 4h
          badcookie-slip: 1

      submission:
        - id: validating-resolver
          parent: recursive
          check-interval: 5m

      policy:
        - id: rsa2048
          algorithm: rsasha256
          ksk-size: 4096
          zsk-size: 2048
          zsk-lifetime: 30d
          ksk-submission: validating-resolver
        - id: ed25519
          algorithm: ed25519
          nsec3: on
          nsec3-iterations: 0
          ksk-lifetime: 360d
          signing-threads: 2
          ksk-submission: validating-resolver
        - id: ed25519_local-push
          algorithm: ed25519
          nsec3: on
          nsec3-iterations: 0
          ksk-lifetime: 360d
          signing-threads: 2
          ksk-submission: validating-resolver
          cds-cdnskey-publish: double-ds
          propagation-delay: 0
          ds-push: [local]

      template:
        - id: default
          global-module: [mod-cookies/default, mod-rrl/default]
        - id: inwx_zone
          storage: /var/lib/knot
          zonefile-sync: -1
          zonefile-load: difference-no-serial
          serial-policy: dateserial
          journal-content: all
          semantic-checks: on
          dnssec-signing: on
          dnssec-policy: ed25519
          notify: [inwx_notify]
          acl: [inwx_acl]
        - id: acme_zone
          storage: /var/lib/knot
          zonefile-sync: -1
          zonefile-load: difference-no-serial
          serial-policy: dateserial
          journal-content: all
          semantic-checks: on
          dnssec-signing: on
          dnssec-policy: ed25519_local-push

      zone:
      ${strings.concatMapStringsSep "\n" mkZone [
        { domain = "as210286.net";
          acmeDomains = ["as210286.net" "${hostName}.as210286.net" "radicale.as210286.net"];
        }
        { domain = "kleen.org";
          acmeDomains = ["kleen.org" "paperless.kleen.org"];
        }
        { domain = "17220103.de";
          acmeDomains = ["17220103.de" "${hostName}.17220103.de"];
        }
        { domain = "zorn-encryption.org";
          acmeDomains = ["zorn-encryption.org"];
        }
      ]}
    '';
  };

  age.secrets = lib.listToAttrs (builtins.map ({name, path}: lib.nameValuePair "dns/${name}" {
    file = path;
    mode = "0400";
    owner = "knot";
  }) knotKeys);

  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    stateDir = "/var/lib/unbound";
    localControlSocketPath = "/run/unbound/unbound.ctl";
    enableRootTrustAnchor = false;

    settings = {
      server = {
        interface = ["lo@5353"];
        prefer-ip6 = true;
        access-control = ["127.0.0.0/8 allow" "::1/128 allow"];
        root-hints = "${pkgs.dns-root-data}/root.hints";
        trust-anchor-file = "${pkgs.dns-root-data}/root.key";
        trust-anchor-signaling = false;

        num-threads = 12;
        so-reuseport = true;
        msg-cache-slabs = 16;
        rrset-cache-slabs = 16;
        infra-cache-slabs = 16;
        key-cache-slabs = 16;

        rrset-cache-size = "100m";
        msg-cache-size = "50m";
        outgoing-range = 8192;
        num-queries-per-thread = 4096;

        so-rcvbuf = "4m";
        so-sndbuf = "4m";

        prefetch = true;
        prefetch-key = true;

        minimal-responses = false;

        extended-statistics = true;

        rrset-roundrobin = true;
        use-caps-for-id = true;

        do-not-query-localhost = false;
      };
    };
  };
}
