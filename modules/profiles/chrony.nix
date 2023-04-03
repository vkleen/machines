{ ... }:
{
  services.chrony = {
    enable = true;
    initstepslew = {
      enabled = true;
      threshold = 1000;
    };
  };
  services.ntp.enable = false;
}