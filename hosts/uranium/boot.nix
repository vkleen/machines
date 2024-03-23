{ config, ... }:
{
  config = {
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.enable = false;
  };
}
