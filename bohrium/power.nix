{config, pkgs, ...}:
let
  powerscript = pkgs.writeShellScriptBin "powerscript.sh" ''
    ${pkgs.powercap}/bin/rapl-set -c 0 -l 10000000
    case "$1" in
      online)
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo "balance_performance" > $i/energy_performance_preference
          echo "powersave" > $i/scaling_governor
        done
        ;;
      offline)
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo "power" > $i/energy_performance_preference
          echo "powersave" > $i/scaling_governor
        done
        ;;
    esac
  '';
in {
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
  };

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options ath9k ps_enable=1
  '';

  environment.systemPackages = [ powerscript ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ATTR{idProduct}=="6047", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5332", ATTR{idProduct}=="1300", TEST=="power/control", ATTR{power/control}="on"

    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8153", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="0411", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5411", TEST=="power/control", ATTR{power/control}="on"

    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${powerscript}/bin/powerscript.sh offline"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${powerscript}/bin/powerscript.sh online"
  '';
}
