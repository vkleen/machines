{ flake, config, hostName, lib, pkgs, ... }:
{
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
    system.machineId = flake.inputs.macname.computeHostId config.system.macnameNamespace config.networking.hostName;
    networking.hostId = builtins.substring 0 8 config.system.machineId;
    environment.etc."machine-id".text = config.system.machineId;
  };
}
