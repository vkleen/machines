{ config, lib, system, inputs, ... }:
{
  options = {
    system.publicAddresses = lib.mkOption {
      type = lib.types.listOf lib.types.networkAddress;
      description = ''
        Publicly routable IP addresses suitable for inclusion into networking.hosts       
      '';
    };
    system.machineId = lib.mkOption {
      type = lib.types.str;
      internal = true;
      description = ''
        Machine ID consistent with requested hostname
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
    networking = {
      hostName = system.hostName;
      hostId = builtins.substring 0 8 config.system.machineId;
    };

    system.machineId = system.computeHostId config.system.macnameNamespace config.networking.hostName;

    environment.etc."machine-id".text = config.system.machineId;
  };
}
