{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/netboot/netboot.nix"
  ];
  config = {
    boot.wipeRoot = false;
    #boot.kernelParams = [ "console=ttyS0" ];
    system.build.netbootIpxeScript = lib.mkForce (pkgs.writeTextDir "netboot.ipxe" ''
      #!ipxe
      kernel http://boron.auenheim.kleen.org/actinium/${pkgs.stdenv.hostPlatform.linux-kernel.target} init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams} ''${cmdline}
      initrd http://boron.auenheim.kleen.org/actinium/initrd
      boot
    '');
    system.build.ipxeTree = pkgs.linkFarm "ipxe-tree" [
      {
        name = "ipxe";
        path = "${pkgs.ipxe}/undionly.kpxe";
      }
      {
        name = "initrd";
        path = "${config.system.build.netbootRamdisk}/initrd";
      }
      {
        name = "bzImage";
        path = "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
      }
      {
        name = "netboot.ipxe";
        path = "${config.system.build.netbootIpxeScript}/netboot.ipxe";
      }
    ];
  };
}
