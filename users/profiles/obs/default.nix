{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.obs-studio
  ];
  xdg.configFile."obs-studio/plugins/v4l2sink".source = "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink";
}
