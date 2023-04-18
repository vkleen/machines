{ pkgs, config, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
  };
}
