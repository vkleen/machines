{ pkgs, lib, ... }:
{
  services.fwupd.enable = lib.mkForce false;

  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];

  nix.settings.keep-outputs = true;
}
