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
in {
  imports = with (lib.findModules ./.); [
    mako
    kanshi
    waybar
    random-background
    swayidle
  ];
  config = {
    home.packages = with pkgs; [
      grim
      wl-clipboard
      slurp
      brightnessctl
    ];
  
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        monitor = [
          ",preferred,auto,auto"
        ];
        input = {
          kb_layout = "us";
          kb_options = "compose:ralt";
          follow_mouse = 0;
          accel_profile = "adaptive";
          touchpad = {
            natural_scroll = true;
            drag_lock = true;
          };
        };
        general = {
          gaps_in = 2;
          gaps_out = 0;
          border_size = 1;
          "col.active_border" = "rgba(${colors.blue}ff)";
          "col.inactive_border" = "rgba(${colors.black}ff)";

          layout = "master";
          no_border_on_floating = false;
        };
        decoration = {
          rounding = 0;
          drop_shadow = false;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
          blur = {
            enabled = false;
          };
        };
        animations = {
          enabled = false;
        };
        master = {
          orientation = "left";
        };

        "$mainMod" = "SUPER";
      };
      extraConfig = ''
        bind = $mainMod SHIFT, Q, killactive
        bind = $mainMod, F, fullscreen,

        bind = $mainMod, H, movefocus, l
        bind = $mainMod, J, movefocus, d
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, L, movefocus, r
        bind = $mainMod SHIFT, H, movewindow, l
        bind = $mainMod SHIFT, J, movewindow, d
        bind = $mainMod SHIFT, K, movewindow, u
        bind = $mainMod SHIFT, L, movewindow, r

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

        bind = $mainMod, Return, exec ${terminal} -e ${open-tmux "persistent"}
      '';
    };
  };
}
