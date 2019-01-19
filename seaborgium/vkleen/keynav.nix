{pkgs, ...}:
{
  home.packages = [ pkgs.keynav ];
  systemd.user.services.keynav = {
    Unit = {
      Description = "keynav";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.keynav}/bin/keynav";
      RestartSec = 3;
      Restart = "on-abort";
    };
  };
}
