{ pkgs, config, lib, ... }:
{
  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "${config.home.homeDirectory}/wallpapers/";
        duration = "1h";
        sorting = "random";
      };
    };
  };
  systemd.user.services.wpaperd = {
    Unit = {
      Description = "Wpaperd wallpaper daemon";
      PartOf = [ "hyprland-session.target" ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.wpaperd;
      RestartSec = 5;
      Restart = "always";
    };
  };
}
