{pkgs, config, lib, ...}:
let cfg = config.services.gammastep;
in {
  services.gammastep = {
    enable = true;
    latitude = "51";
    longitude = "7";
    tray = false;
    temperature = {
      day = 6500;
      night = 3500;
    };
    package = pkgs.gammastep;
  };
}
