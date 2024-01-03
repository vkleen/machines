{ pkgs, ... }:
{
  boot.kernelParams = [
    "acpi_osi=\"!Windows 2020\""
    "nvme.noacpi=1"
    "mem_sleep_default=deep"
    "i915.enable_psr=1"
  ];
  boot.blacklistedKernelModules = [
    "hid-sensor-hub"
    "cros-usbpd-charger"
    "cros_ec_lpcs"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.acpilight.enable = true;
  hardware.opengl.extraPackages = [
    pkgs.intel-vaapi-driver
    pkgs.libvdpau-va-gl
    pkgs.intel-media-driver
  ];

  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.systemPackages = [ pkgs.fw-ectool ];

  services.udev.extraRules = ''
    # Fix headphone noise when on powersave
    # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
  '';
  services.upower.criticalPowerAction = "PowerOff";
}