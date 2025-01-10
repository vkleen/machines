{ config, pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      command = "${lib.getExe' pkgs.dbus "dbus-run-session"} ${lib.getExe pkgs.cage} -s -m last -- ${lib.getExe config.programs.regreet.package}";
      user = "greeter";
    };
  };
  programs.regreet = {
    enable = true;
    settings = {
      commands = {
        poweroff = [ (lib.getExe' pkgs.systemd "systemctl") "poweroff" ];
        reboot = [ (lib.getExe' pkgs.systemd "systemctl") "reboot" ];
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };
}
