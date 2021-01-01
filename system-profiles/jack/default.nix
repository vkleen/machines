{ pkgs, config, ... }:
{
  config = {
    system.extra-profiles = [ "jack" ];
    services.jack = {
      jackd = {
        enable = true;
      };
      alsa.enable = false;
      loopback.enable = true;
    };
  };
}
