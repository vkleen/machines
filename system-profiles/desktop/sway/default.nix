{ pkgs, ... }:
{
  xdg.portal.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
    };
    extraPackages = with pkgs; [
      swaylock swayidle
    ];
  };
}
