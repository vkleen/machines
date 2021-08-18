{pkgs, config, lib, ...}:
let cfg = config.services.wlsunset;
in {
  services.wlsunset = {
    enable = true;
    latitude = "51.5";
    longitude = "7.0";
    temperature = {
      day = 6500;
      night = 3500;
    };
    package = pkgs.wlsunset;
  };
}
