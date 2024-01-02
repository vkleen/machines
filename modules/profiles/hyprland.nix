{ pkgs, lib, ... }:
{
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    xdgOpenUsePortal = true;
  };
}
