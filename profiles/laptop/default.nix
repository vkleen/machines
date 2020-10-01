flake:
{config, pkgs, ...}:
let
  powerscript = pkgs.writeShellScriptBin "powerscript.sh" ''
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
  '';

  environment.systemPackages = [ powerscript ];

  services.logind = {
    lidSwitch = "lock";
    extraConfig = ''
      HandlePowerKey = suspend
      HandleHibernateKey = ignore
      HandleSuspendKey = ignore
      LidSwitchIgnoreInhibited = no
    '';
  };

  services.thermald = {
    enable = true;
    debug = false;
  };

  services.upower.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${powerscript}/bin/powerscript.sh offline"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${powerscript}/bin/powerscript.sh online"
  '';
}
