{ pkgs, config, lib, ... }:
{
  stylix.targets.wpaperd.enable = false;

  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "${config.home.homeDirectory}/wallpapers/";
        duration = "30m";
        sorting = "random";
      };
    };
  };

  systemd.user.services.random-wallpaper = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      Description = "Wpaperd";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.wpaperd;
      IOSchedulingClass = "idle";
    };
  };
}
