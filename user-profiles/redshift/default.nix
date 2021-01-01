{pkgs, config, lib, ...}:
let cfg = config.services.redshift;
in {
  services.redshift = {
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
  systemd.user.services.redshift.Service.ExecStart = let
    args = [
      "-l ${cfg.latitude}:${cfg.longitude}"
      "-t ${toString cfg.temperature.day}:${toString cfg.temperature.night}"
      "-b ${toString cfg.brightness.day}:${toString cfg.brightness.night}"
    ] ++ cfg.extraOptions;
  in lib.mkForce "${cfg.package}/bin/gammastep ${lib.concatStringsSep " " args}";
}
