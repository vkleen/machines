{ pkgs, ... }:
{
  services.avahi = {
    enable = true;
    wideArea = false;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
