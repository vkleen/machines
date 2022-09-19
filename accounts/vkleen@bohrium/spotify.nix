{ config, pkgs, ...}:
{
  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override {
      withALSA = false;
      withPulseAudio = true;
      withMpris = true;
    };
    settings = {
      global = {
        username = "vkleen-spotify@17220103.de";
        password_cmd = "pass spotify.com/vkleen-spotify@17220103.de";
        use_mpris = true;
        bitrate = 320;
        cache_path = "${config.home.homeDirectory}/.local/cache/spotifyd";
        autoplay = true;
        device_name = "bohrium";
        backend = "pulseaudio";
      };
    };
  };
  home.packages = [ pkgs.spotify-tui ];
}
