{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  hardware.framework = {
    laptop13.audioEnhancement.enable = false;
  };


  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [
    pkgs.vaapiVdpau
    pkgs.libvdpau-va-gl
  ];

  environment.systemPackages = [ pkgs.virt-manager pkgs.libva pkgs.fw-ectool ];

  # services.udev = {
  #   extraRules = ''
  #     # Fix headphone noise when on powersave
  #     # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
  #     SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
  #     ACTION=="add", ATTR{idVendor}=="1366", MODE="0660", GROUP="dialout"
  #   '';
  #   extraHwdb = ''
  #     evdev:name:PIXA3854:00 093A:0274 Touchpad:dmi:*svnFramework:*pnLaptop**
  #      EVDEV_ABS_00=::8
  #      EVDEV_ABS_01=::11
  #      EVDEV_ABS_35=::8
  #      EVDEV_ABS_36=::11
  #   '';
  # };
  hardware.bladeRF.enable = true;
  services.upower.criticalPowerAction = "PowerOff";

  programs.nix-ld.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  services.pcscd.enable = true;
}
