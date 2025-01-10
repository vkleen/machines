{ config, lib, pkgs, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  stylix.targets.waybar.enable = false;
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
        modules-right = [ "battery" "temperature" "wireplumber" "backlight" "privacy" "tray" ];
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
        "temperature" = {
          hwmon-path-abs = "/sys/bus/pci/devices/0000:00:18.3/hwmon";
          input-filename = "temp1_input";
          format = "{temperatureC}°C";
        };
        "wireplumber" = {
          format = "{volume}% {node_name}";
          format-mutes = " ";
          on-click = lib.getExe pkgs.helvum;
        };
        "backlight" = let device = "amdgpu_bl1"; in {
          inherit device;
          format = "{percent}%";
          on-scroll-up = "${lib.getExe pkgs.brightnessctl} -d ${device} s +1%";
          on-scroll-down = "${lib.getExe pkgs.brightnessctl} -d ${device} s 1%-";
          on-click = "${lib.getExe pkgs.brightnessctl} -d ${device} s 1%";
        };
        "clock" = {
          format = "{:%d-%m %H:%M %Z}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='${colors.base05}'><b>{}</b></span>";
              days = "<span color='${colors.base05}'><b>{}</b></span>";
              weeks = "<span color='${colors.base07}'><b>W{}</b></span>";
              weekdays = "<span color='${colors.base0A}'><b>{}</b></span>";
              today = "<span color='${colors.base08}'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
            on-click = "shift_reset";
            on-click-right = "mode";
          };
        };
      };
    };
    style = with colors; /*css*/''
      @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
      @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

      @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
      @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};

      * {
        border: none;
        border-radius: 0;
        padding-left: 0;
        padding-right: 0;
        padding-top: 0.2ex;
        padding-bottom: 0.2ex;
        margin: 0;
        min-height: 0;
        font-family: "${config.stylix.fonts.sansSerif.name}";
        font-size: 12pt;
      }

      window#waybar, tooltip {
        background: alpha(@base00, ${builtins.toString config.stylix.opacity.desktop});
        color: @base05;
      }

      tooltip {
        background: @base00;
      }

      label {
        padding-left: 0.5ex;
        padding-right: 0.5ex;
      }

      window#waybar {
        border: none;
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces button {
        font-weight: normal;
        min-width: 1em;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }

      #workspaces button.active {
        color: @base00;
        background-color: @base0D;
      }

      #workspaces button.urgent {
        background-color: @base08;
      }

      #battery.full, #battery.plugged {
        color: @base0B;
      }

      #battery.good {
        color: @base05;
      }

      #battery.warning {
        color: @base09;
      }

      #battery.critical {
        color: @base08;
      }

      @keyframes blink {
        to {
          background-color: @base08;
        }
      }

      #battery.critical:not(.charging) {
        background-color: alpha(@base00, ${builtins.toString config.stylix.opacity.desktop});
        color: @base08;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #waybar > box:nth-child(2) > box:nth-child(3) > * > label, #tray {
        padding: 0 10px;
      }

      #waybar > box:nth-child(2) > box:nth-child(3) > :last-child > label {
        padding-right: 0.5ex;
      }

      #waybar > box:nth-child(2) > box:nth-child(3) > *:not(:first-child) > label, #tray {
        background-image:
          linear-gradient(alpha(@base05, 0), alpha(@base05, 1) 20%, alpha(@base05, 1) 80%, alpha(@base05, 0));
        background-size: 1px 80%;
        background-position: 0 50%;
        background-repeat: no-repeat;
      }
    '';
  };
}
