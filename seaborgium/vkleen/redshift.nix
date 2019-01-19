{pkgs, ...}:
{
  services.redshift = {
    latitude = "34";
    longitude = "-118";
    temperature = {
      day = "6500";
      night = "3500";
    };
    extraOptions = [ "-m randr" ];
  };
}
