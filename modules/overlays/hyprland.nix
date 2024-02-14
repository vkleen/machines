{ inputs, lib, ... }: lib.composeManyExtensions [
  inputs.hyprland.overlays.default
  inputs.hyprlang.overlays.default
  (final: prev: {
    xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.override {
      hyprlang = final.hyprlang;
    };
  })
]
