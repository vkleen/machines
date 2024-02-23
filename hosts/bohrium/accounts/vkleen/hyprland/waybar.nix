{ lib, pkgs, ... }:
let
  colors = import ./colors.nix { };
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    settings = {
      top = {
        layer = "top";
        position = "top";
        modules-left = [ "idle_inhibitor" "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "clock" ];
        modules-right = [ "battery" "wireplumber" "backlight" "tray" ];
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        "hyperland/workspaces" = { };
        "hyprland/submap" = { };
        "battery" = {
          states = {
            full = 100;
            good = 95;
            warning = 30;
            criticial = 15;
          };
          interval = 10;
          full-at = 100;
          format = "{time} {power:.2}W {capacity}%{icon}";
          format-charging = "{time} {power:.2}W {capacity}%";
          format-full = "{power:.2}W {icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
          format-time = "{H}:{M:02}";
        };
        "wireplumber" = {
          format = "{volume}% {node_name}";
          format-mutes = " ";
          on-click = lib.getExe pkgs.helvum;
        };
        "backlight" = {
          device = "intel_backlight";
          format = "{percent}%";
          on-scroll-up = "${lib.getExe pkgs.brightnessctl} -d intel_backlight s +1%";
          on-scroll-down = "${lib.getExe pkgs.brightnessctl} -d intel_backlight s 1%-";
          on-click = "${lib.getExe pkgs.brightnessctl} -d intel_backlight s 1%";
        };
        "clock" = {
          format = "{:%d-%m %H:%M %Z}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      };
    };
    style = ''
      * {
          border: none;
          border-radius: 0;
          padding-left: 0;
          padding-right: 0;
          padding-top: 0.2ex;
          padding-bottom: 0.2ex;
          margin: 0;
          font-family: PragmataPro;
          font-size: 15px;
          min-height: 0;
      }

      label {
          padding-left: 0.5ex;
          padding-right: 0.5ex;
      }

      window#waybar {
          background-color: rgba(42, 46, 56, 0.7) ;
          color: ${colors.fg};
          border: none;
          transition-property: background-color;
          transition-duration: .5s;
      }

      #workspaces button {
          min-width: 1em;
          color: ${colors.fg};
      }

      #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
      }

      #workspaces button.active {
          background-color: ${colors.blue};
          color: ${colors.br_black};
      }

      #workspaces button.urgent {
          background-color: ${colors.red};
          color: ${colors.br_black};
      }

      #mode {
          background-color: ${colors.red};
          color: ${colors.br_black};
      }

      #battery.full, #battery.plugged {
          color: ${colors.green};
      }

      #battery.good {
          color: ${colors.fg};
      }

      #battery.warning {
          color: ${colors.orange};
      }

      #battery.critical {
          color: ${colors.red};
      }

      @keyframes blink {
          to {
              background-color: ${colors.red};
              color: ${colors.br_black};
          }
      }

      #battery.critical:not(.charging) {
          background-color: ${colors.br_black};
          color: ${colors.red};
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      @define-color col_border_solid rgba(187, 194, 207, 1);
      @define-color col_border_trans rgba(187, 194, 207, 0);

      #waybar > box:nth-child(2) > box:nth-child(3) > * > label, #tray {
        padding: 0 10px;
      }

      #waybar > box:nth-child(2) > box:nth-child(3) > :last-child > label {
        padding-right: 0.5ex;
      }

      #waybar > box:nth-child(2) > box:nth-child(3) > *:not(:first-child) > label, #tray {
          background-image:
            linear-gradient(@col_border_trans, @col_border_solid 20%, @col_border_solid 80%, @col_border_trans);
          background-size: 1px 80%;
          background-position: 0 50%;
          background-repeat: no-repeat;
      }
    '';
  };
}
