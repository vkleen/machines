{ lib, pkgs, ... }:
{
  services.mako = {
    enable = true;
    maxVisible = -1;
    borderRadius = 10;
    icons = false;
    defaultTimeout = 6000;
    extraConfig = ''
      [urgency=low]
      default-timeout=4000

      [urgency=normal]
      default-timeout=6000

      [urgency=high]
      default-timeout=8000

      [app-name=Element]
      ignore-timeout=1
      default-timeout=0
    '';
  };
  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "hyprland-session.target" ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = lib.getExe pkgs.mako;
      RestartSec = 5;
      Restart = "always";
    };
  };
}
