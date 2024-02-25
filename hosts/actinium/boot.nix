{ config, pkgs, lib, inputs, ... }:
{
  config = {
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.enable = false;

    system.build.netbootIpxeScript = lib.mkForce (pkgs.writeTextDir "netboot.ipxe" ''
      #!ipxe
      kernel http://boron.auenheim.kleen.org/actinium/${pkgs.stdenv.hostPlatform.linux-kernel.target} init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams} ''${cmdline}
      initrd http://boron.auenheim.kleen.org/actinium/initrd
      boot
    '');

    system.build.kexecScript = pkgs.writeShellScript "kexec-boot" ''
      ${lib.getExe' pkgs.kexec-tools "kexec"} --load \
        ${config.system.build.kernel}/${config.system.boot.loader.kernelFile} \
        --initrd=${config.system.build.initialRamdisk}/initrd \
        --command-line "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
      ${lib.getExe' pkgs.kexec-tools "kexec"} -e
    '';

    system.build.ipxeTree = pkgs.linkFarm "ipxe-tree" [
      {
        name = "ipxe";
        path = "${pkgs.ipxe}/undionly.kpxe";
      }
      {
        name = "initrd";
        path = "${config.system.build.initialRamdisk}/initrd";
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
