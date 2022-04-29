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
        package = pkgs.OVMFFull;
      };
      swtpm = {
        enable = true;
        package = pkgs.swtpm;
      };
    };
  };
}
