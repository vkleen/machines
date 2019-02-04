{pkgs, ...}:
{
  services.redshift = {
    enable = true;
    latitude = "34";
    longitude = "-118";
    tray = true;
    temperature = {
      day = 6500;
      night = 3500;
    };
    extraOptions = [ "-m randr" ];
  };
}
