{ lib, pkgs, ... }:
{
  systemd.user.services.hyprdim = {
    Unit = {
      Description = "Automatically dims windows when switching between them";
      PartOf = [ "hyprland-session.target" ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.hyprdim;
      RestartSec = 5;
      Restart = "always";
    };
  };
}
