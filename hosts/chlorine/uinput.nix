{ ... }:
{
  boot.kernelPatches = [
    {
      name = "uinput-config";
      patch = null;
      extraConfig = ''
        INPUT_MISC y
        INPUT_UINPUT m
      '';
    }
  ];
  hardware.uinput.enable = true;
}
