{config, pkgs, ...}:
{
  powerManagement.cpuFreqGovernor = "powersave";

  systemd.services.cpufreq_preference = {
    description = "CPU energy/performance balance setup";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionVirtualization = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      for d in /sys/devices/system/cpu/cpufreq/*; do
        echo balance_power > $d/energy_performance_preference
      done
    '';
  };

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
  };

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options ath9k ps_enable=1
  '';

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ATTR{idProduct}=="6047", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5332", ATTR{idProduct}=="1300", TEST=="power/control", ATTR{power/control}="on"
  '';
}
