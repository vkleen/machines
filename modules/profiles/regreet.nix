{ pkgs, lib, ... }:
{
  programs.regreet = {
    enable = true;
    settings = {
      commands = {
        poweroff = [ (lib.getExe' pkgs.systemd "systemctl") "poweroff" ];
        reboot = [ (lib.getExe' pkgs.systemd "systemctl") "reboot" ];
      };
      GTK = {
        application_prefer_dark_theme = true;
        font_name = "PragmataPro Mono 16";
      };
    };
  };
}
