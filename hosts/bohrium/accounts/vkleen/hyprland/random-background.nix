{ pkgs, config, lib, ... }:
let
  randomWallpaper = pkgs.writeScriptBin "random-wallpaper" ''
    #!${lib.getExe pkgs.zsh}
    _file=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    _monitor1=eDP-1

    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "''${_file}"
    hyprctl hyprpaper wallpaper "''${_monitor1},''${_file}"
  '';
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
    };
  };
  home.packages = [ randomWallpaper ];

  systemd.user.services.random-wallpaper = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      Description = "Randomize desktop background";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe randomWallpaper;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.random-wallpaper = {
    Timer.OnUnitActiveSec = "30m";
    Install.WantedBy = [ "timers.target" ];
  };
}
