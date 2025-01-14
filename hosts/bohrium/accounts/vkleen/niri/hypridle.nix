{ config, pkgs, lib, inputs, ... }:
let
  hyprlock = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
  lock-session = pkgs.writeScriptBin "lock-session" ''
    #!${lib.getExe pkgs.zsh}
    _background=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    _config="$(mktemp)"
    function on_exit() {
      rm -f "$_config"
    }
    trap on_exit EXIT INT TERM

    BACKGROUND="$_background" ${lib.getExe' pkgs.gettext "envsubst"} '$${BACKGROUND}' <"${config.home.homeDirectory}/${config.xdg.configFile."hypr/hyprlock.conf".target}" >"$_config"
    ${lib.getExe hyprlock} -c "$_config" "$@"
  '';
in
{
  config = {
    home.packages = [ lock-session ];
    programs.hyprlock = {
      enable = true;
      package = hyprlock;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          grace = 5;
        };
        input-field = {
          size = "500, 50";
          position = "0, -80";
          monitor = "";
          hide_input = false;
          dots_center = true;
          fade_on_empty = true;
          outline_thickness = 2;
          shadow_passes = 2;
        };
        background = lib.mkForce [
          {
            path = "$BACKGROUND";
          }
        ];
      };
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "true";
          before_sleep_cmd = "${lib.getExe lock-session} --immediate";
          lock_cmd = lib.getExe lock-session;
          unlock_cmd = "true";
          ignore_dbus_inhibit = false;
        };
        listener = [
          {
            timeout = 300;
            on-timeout = lib.getExe lock-session;
          }
          {
            timeout = 600;
            on-timeout = "${lib.getExe config.programs.niri.package} msg action power-off-monitors";
          }
        ];
      };
    };
  };
}
