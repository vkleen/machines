{ pkgs, config, ... }:
{
  config = {
    services.jack = {
      jackd = {
        enable = true;
      };
      alsa.enable = false;
      loopback.enable = true;
    };
  };
}
