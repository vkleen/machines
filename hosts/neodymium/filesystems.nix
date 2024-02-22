{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  fileSystems."/" =
    {
      device = "/dev/vda3";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/vda2";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
