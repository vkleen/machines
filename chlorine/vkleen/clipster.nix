{ pkgs, ... }:
{
  home.packages = [ pkgs.clipster ];
  systemd.user.services.clipster = {
    Unit = {
      Description = "Lightweight GTK+ clipboard manager";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.clipster}/bin/clipster -d";
      Restart = "on-abort";
    };
  };
}
