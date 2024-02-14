{ ... }:
{
  boot.initrd.availableKernelModules = [
    "nvme"
  ];

  boot.initrd.luks = {
    devices = {
      "chlorine_pv" = {
        device = "/dev/disk/by-uuid/6939b21d-b466-4b00-b79f-cee0ad92efd1";
      };
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/978e4c7d-a137-469e-9fab-b202d02f11c1";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
