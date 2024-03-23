{ pkgs, ... }:
{
  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];
}
