{ inputs, pkgs, lib, ... }:
let
  lock-session = pkgs.writeScriptBin "lock-session" ''
    #!${lib.getExe pkgs.zsh}
    FILE=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    exec ${lib.getExe pkgs.swaylock-effects} -fF -i "$FILE" --grace 5
  '';
in
{
  imports = [ inputs.hypridle.homeManagerModules.default ];
  config = {
    home.packages = [ lock-session ];
    services.hypridle = {
      enable = true;
      lockCmd = lib.getExe lock-session;
      unlockCmd = "true";
      afterSleepCmd = "true";
      beforeSleepCmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
      ignoreDbusInhibit = false;
      listeners = [
        {
          timeout = 600;
          onTimeout = "echo timeout && ${lib.getExe' pkgs.libnotify "notify-send"} 'hypridle onTimeout 600'";
          onResume = "echo resume && ${lib.getExe' pkgs.libnotify "notify-send"} 'hypridle onResume 600'";
        }
      ];
    };
    systemd.user.services.hypridle = {
      Unit.PartOf = [ "hyprland-session.target" ];
      Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
    };
  };
}
