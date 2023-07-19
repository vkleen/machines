{ pkgs, lib, config, inputs, ... }:
{
  imports = [ "${inputs.nixpkgs.outPath}/nixos/modules/installer/netboot/netboot-minimal.nix" ];
  config.system.build.netboot = pkgs.symlinkJoin {
    name = "netboot";
    paths = lib.attrValues {
      inherit (config.system.build)
        netbootRamdisk
        kernel
        netbootIpxeScript;
    };
    preferLocalBuild = true;
  };
}
