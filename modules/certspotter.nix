{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.certspotter;

  script = pkgs.writeShellApplication {
    name = "certspotter-script";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      mkdir -p "''${LOGS_DIRECTORY}"
      env > "$(mktemp -p "''${LOGS_DIRECTORY}" "$(date -Iseconds).XXXXXXXXXX.env")"
    '';
  };

  startOptions = cfg.extraOptions
                 ++ optionals (cfg.logs != null) ["-logs" cfg.logs]
                 ++ ["-watchlist" (pkgs.writeText "watchlist" (concatStringsSep "\n" cfg.watchList))
                     "-script" "${script}/bin/certspotter-script"
                    ];

  startScript = pkgs.writeShellApplication {
    name = "certspotter-start";
    runtimeInputs = [ pkgs.coreutils cfg.package ];
    text = ''
      rm -f "''${STATE_DIRECTORY}/lock"
      exec -- certspotter -state_dir "''${STATE_DIRECTORY}" ${escapeShellArgs startOptions}
    '';
  };
in {
  options = {
    services.certspotter = {
      watchList = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      logs = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      extraOptions = mkOption {
        type = types.listOf types.str;
        default = [ "-verbose" ];
      };

      package = mkPackageOption pkgs "certspotter" {};
    };
  };

  config = mkIf (cfg.watchList != []) {
    systemd.services.certspotter = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${startScript}/bin/certspotter-start";
        StateDirectory = "certspotter";
        LogsDirectory = "certspotter";
        DynamicUser = true;

        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
      };
    };
  };
}
