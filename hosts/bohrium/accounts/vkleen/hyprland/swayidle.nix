{ lib, pkgs, ... }:
{
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 600; command = "${lib.getExe pkgs.swaylock} -fF"; }
      { timeout = 1200; command = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms off"; }
    ];
    events = [
      { event = "before-sleep"; command = "${lib.getExe pkgs.swaylock} -fF"; }
      { event = "lock"; command = "${lib.getExe pkgs.swaylock} -fF"; }
      { event = "resume"; command = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms on"; }
    ];
    systemdTarget = "hyprland-session.target";
  };
  systemd.user.services.swayidle.Unit.PartOf = lib.mkForce [ "hyprland-session.target" ];
}
