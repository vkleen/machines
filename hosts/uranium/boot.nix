{ ... }:
{
  config = {
    boot.kernelParams = [ "console=ttyS0" "intel_iommu=on" ];
    boot.loader.grub.enable = false;
  };
}
