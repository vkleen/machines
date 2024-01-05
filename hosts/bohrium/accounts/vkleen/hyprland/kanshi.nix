{ pkgs, ... }:
{
  home.packages = [ pkgs.kanshi ];
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      nomad = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2256x1504";
            position = "0,0";
            scale = 1.0;
          }
        ];
      };
      desk = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2256x1504";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "Unknown ASUS PB27U 0x0000388B";
            status = "enable";
            mode = "3840x2160@60Hz";
            position = "3000,0";
            scale = 1.0;
          }
        ];
      };
    };
  };
}
