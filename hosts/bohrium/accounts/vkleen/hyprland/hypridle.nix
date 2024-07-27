{ pkgs, lib, ... }:
let
  lock-session = pkgs.writeScriptBin "lock-session" ''
    #!${lib.getExe pkgs.zsh}
    FILE=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    exec ${lib.getExe pkgs.swaylock-effects} -fF -i "$FILE" --grace 5
  '';
in
{
  config = {
    home.packages = [ lock-session ];
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "true";
          before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          lock_cmd = lib.getExe lock-session;
          unlock_cmd = "true";
          ignore_dbus_inhibit = false;
        };
        listeners = [
          {
            timeout = 600;
            on-timeout = "echo timeout && ${lib.getExe' pkgs.libnotify "notify-send"} 'hypridle onTimeout 600'";
            on-resume = "echo resume && ${lib.getExe' pkgs.libnotify "notify-send"} 'hypridle onResume 600'";
          }
        ];
      };
    };
    systemd.user.services.hypridle = {
      Unit.PartOf = [ "hyprland-session.target" ];
      Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
    };
  };
}
