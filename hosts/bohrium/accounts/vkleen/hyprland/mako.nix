{ lib, pkgs, ... }:
let
  colors = import ./colors.nix {};
in {
  services.mako = {
    enable = true;
    maxVisible = -1;
    font = "PragmataPro Mono Liga";
    backgroundColor = colors.bg;
    textColor = colors.fg;
    borderColor = colors.green;
    borderRadius = 10;
    icons = false;
    defaultTimeout = 6000;
    extraConfig = ''
      [urgency=low]
      border-color=${colors.cyan}
      default-timeout=4000

      [urgency=normal]
      border-color=${colors.green}
      default-timeout=6000

      [urgency=high]
      border-color=${colors.red}
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
