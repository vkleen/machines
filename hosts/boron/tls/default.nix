{ flake, config, lib, pkgs, ... }:
with lib;
let
  tsigSecretName = domain: "${domain}_tsig";

  cfg = config.security.acme;
  domainOptions = {
    options = {
      wildcard = mkOption {
        type = types.bool;
        default = false;
      };
      zone = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      certCfg = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };
in {
  options = {
    security.acme = {
      domains = mkOption {
        type = types.attrsOf (types.submodule domainOptions);
        default = {};
      };
    };
  };
  config = {
    security.acme = {
      acceptTerms = true;
      preliminarySelfsigned = true;
      defaults = {
        email = "vkleen-acme@17220103.de";
        keyType = "rsa4096";
        extraLegoRenewFlags = [];
        extraLegoRunFlags = cfg.defaults.extraLegoRenewFlags;
      };
      certs = let
        domainAttrset = domain: let
          tsigPath = ./tsig_keys + "/${domain}.age";
          tsigSecret = "/run/agenix/tls/${tsigSecretName domain}";
          isTsig = pathExists tsigPath;
          mkRFC2136 = {
            inherit domain;
            extraDomainNames = optional cfg.domains.${domain}.wildcard "*.${domain}";
            dnsResolver = "127.0.0.1:53";
            dnsProvider = "rfc2136";
            credentialsFile = pkgs.writeText "${domain}_credentials.env" ''
              RFC2136_NAMESERVER=ns.as210286.net:53
              RFC2136_TSIG_ALGORITHM=hmac-sha256.
              RFC2136_TSIG_KEY=${domain}_acme_key
              RFC2136_TSIG_SECRET_FILE=${tsigSecret}
              RFC2136_TTL=0
              RFC2136_PROPAGATION_TIMEOUT=60
              RFC2136_POLLING_INTERVAL=2
              RFC2136_SEQUENCE_INTERVAL=1
            '';
          };
        in assert isTsig; mkRFC2136 // cfg.domains.${domain}.certCfg;
      in genAttrs (attrNames cfg.domains) domainAttrset;
    };
    age.secrets = let
      dir = ./tsig_keys;
      tsigKeys = filter (v: v != null)
        (mapAttrsToList (n: v:
          if (v == "regular" || v == "symlink") && hasSuffix ".age" n
          then { path = dir + "/${n}"; domain = removeSuffix ".age" n; }
          else null
        ) (builtins.readDir dir));
    in listToAttrs (builtins.map ({domain, path}: nameValuePair "tls/${tsigSecretName domain}" {
      file = path;
      mode = "0440";
      owner = if cfg.useRoot then "root" else "acme";
      group = "acme";
    }) tsigKeys);
  };
}
