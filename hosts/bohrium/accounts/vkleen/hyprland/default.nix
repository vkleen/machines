{ lib, pkgs, ... }:
let
  colors = import ./colors.nix { hash = false; };
  terminal = lib.getExe pkgs.foot;

  open-tmux = session: pkgs.writeShellScript "open-tmux" ''
    if ${lib.getExe pkgs.tmux} has-session -t ${session}; then
      if [ "$1" == "-e" ]; then
        exec ${lib.getExe pkgs.tmux} new-session -t ${session} \; set-option destroy-unattached on
      else
        exec ${lib.getExe pkgs.tmux} new-session -t ${session} \; set-option destroy-unattached on \; new-window
      fi
    else
      exec ${lib.getExe pkgs.tmux} new-session -t ${session} \; set-option destroy-unattached off
    fi
  '';

  switch-window = pkgs.writeShellApplication
    {
      name = "switch-window";
      runtimeInputs = with pkgs; [
        fuzzel
        gawk
        gojq
        hyprland
      ];
      text = ''
        state="$(hyprctl -j clients)"
        active_window="$(hyprctl -j activewindow)"

        current_addr="$(echo "$active_window" | gojq -r '.address')"

        window="$(echo "$state" |
            gojq -r '.[] | select(.monitor != -1 ) | "\(.title)\t\(.workspace.name)\t\(.address)"' |
            fuzzel --log-level=warning --dmenu)"

        addr="$(echo "$window" | awk -F $'\t' '{print $3}')"
        ws="$(echo "$window" | awk -F $'\t' '{print $2}')"

        if [[ "$addr" = "$current_addr" ]]; then
            exit 0
        fi

        fullscreen_on_same_ws="$(echo "$state" | gojq -r ".[] | select(.fullscreen == true) | select(.workspace.name == \"$ws\") | .address")"

        if [[ "$window" != "" ]]; then
            if [[ "$fullscreen_on_same_ws" == "" ]]; then
                hyprctl dispatch focuswindow address:"''${addr}"
            else
                # If we want to focus app_A and app_B is fullscreen on the same workspace,
                # app_A will get focus, but app_B will remain on top.
                # This monstrosity is to make sure app_A will end up on top instead.
                # XXX: doesn't handle fullscreen 0, but I don't care.
                hyprctl --batch "dispatch focuswindow address:''${fullscreen_on_same_ws}; dispatch fullscreen 1; dispatch focuswindow address:''${addr}; dispatch fullscreen 1"
            fi
        fi
      '';
    };

  fuzzel-pass = pkgs.writeShellApplication
    {
      name = "fuzzel-pass";
      runtimeInputs = with pkgs; [
        fuzzel
        gopass
        wtype
      ];
      text = ''
        password=$(gopass list -f | fuzzel --dmenu --log-level=warning)
        [[ -n "$password" ]] || exit 0

        gopass show -o "$password" | wtype -s 100 -
      '';
    };

  fuzzel-pdf = pkgs.writeShellApplication
    {
      name = "fuzzel-pdf";
      runtimeInputs = with pkgs; [
        fuzzel
        ripgrep
        zathura
      ];
      text = ''
        prefix=(~/dl ~/books)
        function _do_select() {
          rg -0 --files --sortr=modified --iglob '*.{pdf,djvu}' "''${prefix[@]}" \
            | fuzzel --log-level=warning --dmenu0
        }

        file=$(_do_select)
        exec zathura "$file"
      '';
    };

  ff-url-candidates = pkgs.writeScriptBin "ff-url-candidates" ''
    #!${lib.getExe pkgs.zsh}
    _profile="$1"
    function do_sqlite() {
      ${lib.getExe pkgs.sqlite} -separator $'\t' "$1" #| tr '\n' '\0'      
    }
    TMPPREFIX=''${XDG_RUNTIME_DIR:-/tmp/}/ff-url-candidates
    do_sqlite =(< ''${_profile}/places.sqlite) <<EOF
    select url, title from (select url, title, max(last_visit_date) as last_visit_date from moz_places group by url) t order by last_visit_date desc
    EOF
  '';

  ff-url = pkgs.writeScriptBin "ff-url" ''
    #!${lib.getExe pkgs.zsh}
    setopt EXTENDED_GLOB
    _profile_=( ~/.mozilla/firefox/*.default )
    _profile="''${_profile_[1]}"
    ${lib.getExe ff-url-candidates} "$_profile" \
      | ${lib.getExe pkgs.rofi} -dmenu \
      | ${lib.getExe pkgs.gawk} 'BEGIN {FS="\t"; OFS="\t"}; {print $1}'
  '';
in
{
  imports = with (lib.findModules ./.);
    [
      hyprdim
      kanshi
      mako
      random-background
      swayidle
      waybar
      redshift
    ];
  config = {
    home.packages = with pkgs; [
      grim
      wl-clipboard
      slurp
      brightnessctl
      hyprnome
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        monitor = [
          "eDP-1,preferred,auto,1.0"
          ",preferred,auto,1.0"
        ];
        input = {
          kb_layout = "us";
          kb_options = "compose:ralt";
          follow_mouse = 2;
          touchpad = {
            natural_scroll = true;
            drag_lock = true;
          };
        };
        "device:pixa3854:00-093a:0274-touchpad" = {
          accel_profile = "custom 0.2144477506 0.000 0.512 1.025 1.794 2.565 3.336 4.175 5.346 6.517 7.688 8.859 10.029 11.200 12.371 13.542 14.713 15.884 17.054 18.225 20.645";
          sensitivity = 0.0;
          natural_scroll = true;
          drag_lock = true;
        };
        general = {
          gaps_in = 5;
          gaps_out = 0;
          border_size = 1;
          "col.active_border" = "rgba(${colors.blue}ff)";
          "col.inactive_border" = "rgba(${colors.black}ff)";

          layout = "master";
          no_border_on_floating = false;

          cursor_inactive_timeout = 1;
        };
        misc = {
          vfr = true;
          vrr = 1;
          new_window_takes_over_fullscreen = 2;
        };
        decoration = {
          rounding = 10;
          drop_shadow = false;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
          blur = {
            enabled = false;
          };
        };
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 2, myBezier"
            "windowsOut, 1, 2, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 2, default"
            "workspaces, 1, 2, default"
          ];
        };
        master = {
          orientation = "left";
        };

        windowrulev2 = [
          "nomaximizerequest, class:.*"
        ];

        "$mainMod" = "SUPER";
      };
      extraConfig = ''
        bind = $mainMod SHIFT, X, exec, ${lib.getExe pkgs.wlogout}
        bind = $mainMod SHIFT CONTROL, X, exit
        bind = $mainMod SHIFT, Q, killactive
        bind = $mainMod, F, fullscreen, 1
        bind = $mainMod SHIFT, F, fullscreen, 0

        bind = $mainMod, H, movefocus, l
        bind = $mainMod, J, movefocus, d
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, L, movefocus, r
        bind = $mainMod SHIFT, H, movewindoworgroup, l
        bind = $mainMod SHIFT, J, movewindoworgroup, d
        bind = $mainMod SHIFT, K, movewindoworgroup, u
        bind = $mainMod SHIFT, L, movewindoworgroup, r

        bind = $mainMod, N, movefocus, l
        bind = $mainMod, E, movefocus, d
        bind = $mainMod, I, movefocus, u
        bind = $mainMod, O, movefocus, r
        bind = $mainMod SHIFT, N, movewindoworgroup, l
        bind = $mainMod SHIFT, E, movewindoworgroup, d
        bind = $mainMod SHIFT, I, movewindoworgroup, u
        bind = $mainMod SHIFT, O, movewindoworgroup, r

        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        bind = $mainMod CONTROL, H, exec, ${lib.getExe pkgs.hyprnome} --previous
        bind = $mainMod CONTROL, L, exec, ${lib.getExe pkgs.hyprnome}

        bind = $mainMod SHIFT CONTROL, H, movecurrentworkspacetomonitor, l
        bind = $mainMod SHIFT CONTROL, J, movecurrentworkspacetomonitor, d
        bind = $mainMod SHIFT CONTROL, K, movecurrentworkspacetomonitor, u
        bind = $mainMod SHIFT CONTROL, L, movecurrentworkspacetomonitor, r
        bind = $mainMod SHIFT CONTROL, N, movecurrentworkspacetomonitor, l
        bind = $mainMod SHIFT CONTROL, E, movecurrentworkspacetomonitor, d
        bind = $mainMod SHIFT CONTROL, I, movecurrentworkspacetomonitor, u
        bind = $mainMod SHIFT CONTROL, O, movecurrentworkspacetomonitor, r

        bind = $mainMod, GRAVE, workspace, name:vid
        bind = $mainMod SHIFT, GRAVE, movetoworkspace, name:vid

        bind = $mainMod, T, workspace, name:chat
        bind = $mainMod SHIFT, T, movetoworkspace, name:chat

        bind = $mainMod, W, exec, ${lib.getExe switch-window}

        bind = $mainMod SHIFT, SPACE, togglefloating

        bind = $mainMod SHIFT, P, exec, ${lib.getExe fuzzel-pass}

        bind = $mainMod, Return, exec, ${terminal} -e ${open-tmux "persistent"}
        bind = $mainMod SHIFT, Return, exec, ${terminal}

        bind = $mainMod, P, exec, ${lib.getExe fuzzel-pdf}

        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
      '';
    };
  };
}
