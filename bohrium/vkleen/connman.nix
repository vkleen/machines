{ pkgs, ... }:
{
  systemd.user.services.connmanui = {
    Unit = {
      Description = "Connman UI";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.connmanui}/bin/connman-ui-gtk";
    };
  };

  systemd.user.services.connman-notify = {
    Unit = {
      Description = "Connman Notification Daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
      Wants = [ "dunst.service" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.connman-notify}/bin/connman-notify";
    };
  };
}
