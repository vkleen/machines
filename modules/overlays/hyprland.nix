{ inputs, lib, ... }: lib.composeManyExtensions [
  inputs.hyprland.overlays.default
  inputs.hypridle.overlays.default
  (final: prev: {
    xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.override {
      hyprlang = final.hyprlang;
    };
    waybar = prev.waybar.override { hyprland = final.hyprland; };
  })
]
