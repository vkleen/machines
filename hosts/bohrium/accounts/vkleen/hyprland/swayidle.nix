{ lib, pkgs, ... }:
let
  do-lock = pkgs.writeScript "do-lock" ''
    #!${lib.getExe pkgs.zsh}
    FILE=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    exec ${lib.getExe pkgs.swaylock-effects} -fF -i "$FILE" --fade-in 0.5 --grace 5
  '';
in
{
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 600; command = "${do-lock}"; }
      {
        timeout = 1200;
        command = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms off";
        resumeCommand = "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms on";
      }
    ];
    events = [
      { event = "before-sleep"; command = "${do-lock}"; }
      { event = "lock"; command = "${do-lock}"; }
    ];
    systemdTarget = "hyprland-session.target";
  };
  systemd.user.services.swayidle.Unit.PartOf = lib.mkForce [ "hyprland-session.target" ];
}
