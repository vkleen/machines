{ inputs, ... }:
final: prev: {
  waybar = prev.waybar.overrideAttrs (o: {
    src = inputs.waybar;
  });
}
