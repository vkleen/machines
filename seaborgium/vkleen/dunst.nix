{config, nixos, pkgs, lib, ...}:

{
  services.dunst = let
    browser = pkgs.writeScriptBin "open" ''
      #!${pkgs.runtimeShell}
      XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
      XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"

      qute_session=default
      socket=$(echo "$XDG_RUNTIME_DIR"/qutebrowser/"$qute_session"/runtime/ipc*)

      [[ -S "$socket" ]] || exit 1

      wakeup () {
          local pid=$1
          childs=( $(pgrep -fP $pid) )
          for c in "''${childs[@]}"; do
              wakeup "$c"
          done
          kill -CONT "$pid"
      }

      ( wakeup "$(< "$XDG_RUNTIME_DIR"/qutebrowser/$qute_session/pid)" ) &
      ${pkgs.jq}/bin/jq -crns \
          '{ args: $ARGS.positional, target_arg: null, version: $ARGS.named["version"], protocol_version: 1 }' \
          --arg version 1.5.2 --args ":open -t $@" \
              | ${pkgs.socat}/bin/socat - "$socket"
    '';
  in {
    enable = true;
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
      size = "32x32";
    };
    settings = {
      global = {
        font = "PragmataPro 13";
        format = "<b>%s</b>\\n%b";
        geometry = "300x5-30+50";
        separator_color = "frame";
        icon_position = "off";
        separator_height = 2;
        padding = 6;
        horizontal_padding = 6;
        stack_duplicates = "yes";
        hide_duplicates_count = "yes";
        indicate_hidden = "yes";
        alignment = "center";
        word_wrap = "yes";
        frame_width = 3;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu";
        browser = "${browser}/bin/open";
      };
      shortcuts = {
        context = "ctrl+shift+period";
      };
      urgency_low = {
        frame_color = "#51afef";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 4;
      };
      urgency_normal = {
        frame_color = "#98be65";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 6;
      };
      urgency_critical = {
        frame_color = "#ff6c6b";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 8;
      };
      rime_ignore = {
        summary = "*Rime*";
        format = "";
      };
      signed_on_ignore = {
        appname = "libpurple";
        summary = "*signed on*";
        format = "";
      };
      signed_off_ignore = {
        appname = "libpurple";
        summary = "*signed off*";
        format = "";
      };
      came_back_ignore = {
        appname = "libpurple";
        summary = "*came back*";
        format = "";
      };
      went_away_ignore = {
        appname = "libpurple";
        summary = "*went away*";
        format = "";
      };
    };
  };
}
