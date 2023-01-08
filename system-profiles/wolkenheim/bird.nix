{ flake, config, hostName, lib, pkgs, ... }:
let
  cfg = config.services.bird2;
in
{
  options = {
    services.bird2.credentialFile = lib.mkOption {
      description = "Encrypted credential file for BIRD";
      default = null;
      type = lib.types.nullOr lib.types.path;
    };
  };
  config = lib.mkMerge [
    {
      systemd.services.bird2 = let
        script = pkgs.writeShellScript "bird-start" ''
          set -e
          umask 077
          export $(xargs < "''${CREDENTIALS_DIRECTORY}"/bird-credentials)
          ${pkgs.envsubst}/bin/envsubst -i /etc/bird/bird2.conf > "$RUNTIME_DIRECTORY"/bird2.conf
          ${pkgs.bird}/bin/bird -c "$RUNTIME_DIRECTORY"/bird2.conf
        '';
      in {
        serviceConfig = {
          ExecStart = lib.mkForce script;
          LoadCredential = lib.lists.optional (cfg.credentialFile != null) "bird-credentials:/run/agenix/bird-credentials";
        };
      };
    }
    (lib.mkIf (cfg.credentialFile != null) {
      age.secrets."bird-credentials".file = cfg.credentialFile;
    })
  ];
}
