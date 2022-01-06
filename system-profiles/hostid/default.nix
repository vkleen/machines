{ flake, config, hostName, lib, pkgs, ... }:
let
  generateHostid = namespace: element: builtins.fromJSON (builtins.readFile (pkgs.runCommandNoCC "generate-hostid"
    { buildInputs = [
        flake.inputs.macname.packages."${config.nixpkgs.system}".macname
        pkgs.coreutils
      ];
    } ''
      printf '"%s"\n' "$(macname -q search "${namespace}" "${element}")" > $out
    ''));
in {
  options = {
    system.machineId = lib.mkOption {
      type = lib.types.str;
      internal = true;
      description = ''
        Machine ID constitent with requested hostname
      '';
    };
    system.macnameNamespace = lib.mkOption {
      type = lib.types.str;
      description = ''
        Namespace for hostid generation from hostname
      '';
    };
  };
  config = {
    networking.hostName = hostName;
    system.machineId = generateHostid config.system.macnameNamespace config.networking.hostName;
    networking.hostId = builtins.substring 0 8 config.system.machineId;
    environment.etc."machine-id".text = config.system.machineId;
  };
}
