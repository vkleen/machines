{ pkgs, ... }:
{
  xdg.configFile = {
    "wireplumber" = {
      source = ./config;
      recursive = true;
      onChange = ''
        ${pkgs.systemd}/bin/systemctl --user try-restart wireplumber
      '';
    };
  };
}
