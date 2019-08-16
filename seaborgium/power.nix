{config, pkgs, ...}:
{
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
  };

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options ath9k ps_enable=0
  '';

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ATTR{idProduct}=="6047", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5332", ATTR{idProduct}=="1300", TEST=="power/control", ATTR{power/control}="on"

    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.powerscript}/bin/powerscript.sh offline"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.powerscript}/bin/powerscript.sh online"
  '';
}
