{ config, pkgs, lib, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
    };
    extraPackages = with pkgs; [
      swaylock swayidle
      xwayland
    ];
  };
}
