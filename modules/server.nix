{ inputs, ... }:
{
  boot.vesa = false;

  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
  ];

  systemd.enableEmergencyMode = false;

  boot.loader.grub.splashImage = null;
}
