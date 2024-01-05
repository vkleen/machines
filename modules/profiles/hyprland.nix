{ ... }:
{
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    xdgOpenUsePortal = true;
  };
  security.pam.services.swaylock = { };
}
