{flake, config, pkgs, ...}:
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "suspend";
    qemu = {
      runAsRoot = false;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull];
      };
      swtpm = {
        enable = true;
        package = pkgs.swtpm;
      };
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  fileSystems."/var/lib/libvirt" = {
    device = "bohrium/local/libvirt";
    fsType = "zfs";
  };

  systemd.services.libvirtd.path = let
    cfg = config.virtualisation.libvirtd;
  in [ cfg.qemu.package cfg.qemu.swtpm.package pkgs.virtiofsd ];
}
