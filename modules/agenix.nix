{pkgs, lib, config, flake, ...}:
{
  imports = [ flake.inputs.agenix.nixosModules.age ];
  systemd.tmpfiles.rules = [
    "d /run/secrets 0751 root ${toString config.ids.gids.keys}"
    "z /run/secrets 0751 root ${toString config.ids.gids.keys}"
  ];
  boot.specialFileSystems = {
    "/run/secrets" = { fsType = "ramfs"; options = [ "nosuid" "nodev" "mode=751" ]; };
  };
}
