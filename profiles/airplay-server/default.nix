{ pkgs, ... }:
{
  # services.avahi = {
  #   enable = true;
  #   wideArea = false;
  #   publish = {
  #     enable = true;
  #     userServices = true;
  #   };
  # };

  services.usbmuxd = {
    enable = true;
  };
}
