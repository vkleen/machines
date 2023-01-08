{ flake, config, hostName, lib, pkgs, ... }:
let
  cfg = config.networking.gobgpd;
in {
  options = {
    networking.gobgpd = {
      enable = lib.mkEnableOption "GoBGP dameon";
      config = lib.mkOption {
        description = "GoBGP configuration";
        type = (pkgs.formats.toml {}).type;
      };
      credentialFile = lib.mkOption {
        description = "Encrypted credential file for GoBGP";
        default = null;
        type = lib.types.nullOr lib.types.path;
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.gobgpd = let # TODO: Add zebra dependency
        configFile = (pkgs.formats.toml {}).generate "gobgpd.conf" cfg.config;
        finalConfigFile = "$RUNTIME_DIRECTORY/gobgpd.conf";
      in {
        wantedBy = [ "multi-user.target" ];
        requires = [ "network.target" "systemd-sysctl.service" ];
        after = [ "network.target" "systemd-sysctl.service" ];
        description = "GoBGP Routing Daemon";
        script = ''
          umask 077
          export $(xargs < "''${CREDENTIALS_DIRECTORY}"/gobgp-credentials)
          ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
          exec ${pkgs.gobgpd}/bin/gobgpd -f "${finalConfigFile}" --sdnotify --pprof-disable --api-hosts=unix://"$RUNTIME_DIRECTORY/gobgpd.sock"
        '';
        serviceConfig = {
          Type = "notify";
          RestartSec = "5s";
          Restart = "always";
          DynamicUser = lib.mkDefault true;
          RuntimeDirectoryMode = "0700";
          RuntimeDirectory = "gobgpd";
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          LoadCredential = lib.lists.optional (cfg.credentialFile != null)
            "gobgp-credentials:/run/agenix/gobgp-credentials";
        };
      };

      environment.systemPackages = [
        pkgs.gobgp
      ];
    })
    (lib.mkIf (cfg.credentialFile != null) {
      age.secrets."gobgp-credentials".file = cfg.credentialFile;
    })
  ];
}
