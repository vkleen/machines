self: super: {
  powerscript = self.writeShellScriptBin "powerscript.sh" ''
      ${self.powercap}/bin/rapl-set -c 0 -l 10000000
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
}
