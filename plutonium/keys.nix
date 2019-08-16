{config, pkgs, lib, ...}:
with lib;
let
  keyOpts = { config, name, ... }: {
    options = {
      destDir = mkOption {
        default = "/run/keys";
        type = types.path;
      };
      path = mkOption {
        default = "${config.destDir}/${name}";
        type = types.path;
        internal = true;
      };
      user = mkOption {
        default = "root";
        type = types.str;
        description = ''
          The user which will be the owner of the key file.
        '';
      };

      group = mkOption {
        default = "root";
        type = types.str;
        description = ''
          The group that will be set for the key file.
        '';
      };

      permissions = mkOption {
        default = "0600";
        example = "0640";
        type = types.str;
        description = ''
          The default permissions to set for the key file, needs to be in the
          format accepted by <citerefentry><refentrytitle>chmod</refentrytitle>
          <manvolnum>1</manvolnum></citerefentry>.
        '';
      };
    };
  };
in {
  options = {
    keys = mkOption {
      default = {};
      type = types.attrsOf (types.submodule keyOpts);
    };
  };
  config = {
    system.activationScripts.manual-keys =
      let script = ''
        mkdir -p /run/keys -m 0750
        chown root:keys /run/keys
        ${concatStringsSep "\n" (flip mapAttrsToList config.keys (name: value:
              # Make sure each key has correct ownership, since the configured owning
              # user or group may not have existed when first uploaded.
              ''
                [[ -f "${value.path}" ]] && chown '${value.user}:${value.group}' "${value.path}"
              ''
        ))}
      '';
      in stringAfter [ "users" "groups"] "source ${pkgs.writeText "setup-keys.sh" script}";
    systemd.services = {
      "manual-keys" = {
        enable = true;
        description = "Waiting for manual key copy";
        wantedBy = [ "keys.target" ];
        before = [ "keys.target" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          while ! [ -e /run/keys/done ]; do
            sleep 0.1
          done
        '';
      };
    } // (flip mapAttrs' config.keys (name: keyCfg:
    nameValuePair "${name}-key" {
      enable = true;
      serviceConfig.TimeoutStartSec = "infinity";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = "100ms";
      path = [ pkgs.inotifyTools ];
      preStart = ''
        (while read f; do if [ "$f" = "${name}" ]; then break; fi; done \
          < <(inotifywait -qm --format '%f' -e create,move ${keyCfg.destDir} ) ) &
          if [[ -e "${keyCfg.path}" ]]; then
            echo 'flapped down'
            kill %1
            exit 0
          fi
          wait %1
      '';
      script = ''
        inotifywait -qq -e delete_self "${keyCfg.path}" &
        if [[ ! -e "${keyCfg.path}" ]]; then
          echo 'flapped up'
          exit 0
        fi
        wait %1
      '';
    }
    ));
  };
}
