{config, pkgs, ...}:

{
  systemd.services.suspend-to-hibernate = {
    description = "Delayed hibernation trigger";
    before = [ "sleep.target" ];
    unitConfig = {
      StopWhenUnneeded = "true";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      echo +1800 > /sys/class/rtc/rtc0/wakealarm
    '';
    preStop = ''
      alarm=$(cat /sys/class/rtc/rtc0/wakealarm);
      now=$(date +%s);

      if [[ -z "$alarm" ]] || [[ $now -ge $alarm ]]; then
        echo "hibernate triggered";
        systemctl hibernate
      fi
      echo 0 > /sys/class/rtc/rtc0/wakealarm
    '';
  };

  systemd.targets.sleep = {
    wants = [ "suspend-to-hibernate.service" ];
  };

  systemd.services.suspend-to-hibernate.enable = false;
}
