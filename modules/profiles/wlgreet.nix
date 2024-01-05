{ pkgs, lib, ... }:
let
  greeter-sway-config = pkgs.writeText "sway-config" ''
    exec "${pkgs.greetd.wlgreet}/bin/wlgreet; ${pkgs.sway}/bin/swaymsg exit"
    bindsym Mod4+shift+e exec ${pkgs.sway}/bin/swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Power off' '${pkgs.systemd}/bin/systemctl poweroff' \
      -b 'Reboot' '${pkgs.systemd}/bin/systemctl reboot'
  '';

  hyprland = pkgs.writeShellScript "hyprland" ''
    WLR_DRM_NO_MODIFIERS=1
    exec Hyprland "$@"
  '';
in
{
  environment.etc = {
    "greetd/wlgreet.toml".source = (pkgs.formats.toml { }).generate "wlgreet.toml" {
      command = hyprland;
      outputMode = "all";
      scale = 1;
    };
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${greeter-sway-config}";
        user = "greeter";
      };
    };
  };
}
