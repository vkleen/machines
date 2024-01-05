{ pkgs, lib, ... }:
{
  xdg.configFile."wluma/config.toml".text = ''
    [als.iio]
    path = "/sys/bus/iio/devices"
    thresholds = { 0 = "night", 20 = "dark", 80 = "dim", 250 = "normal", 500 = "bright", 800 = "outdoors" }
    [[output.backlight]]
    name = "eDP-1"
    path = "/sys/class/backlight/intel_backlight"
    capturer = "wlroots"
  '';
  systemd.user.services.wluma = {
    Unit = {
      Description = "Automatically adjust screen brightness";
      PartOf = [ "hyprland-session.target" ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.wluma;
      RestartSec = 5;
      Restart = "always";
      PrivateNetwork = true;
    };
  };
}
