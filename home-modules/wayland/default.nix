{ config, pkgs, nixos, lib, flake, ... }:
let
  start-sway = pkgs.writeShellScriptBin "start-sway" ''
    # first import environment variables from the login manager
    systemctl --user import-environment
    # then start the service
    exec systemctl --user start sway.service
  '';

  get-swaysock = ''
    export SWAYSOCK=/run/user/$(${pkgs.coreutils}/bin/id -u)/sway-ipc.$(${pkgs.coreutils}/bin/id -u).$(${pkgs.procps}/bin/pgrep -f 'sway$').sock
    export WAYLAND_DISPLAY=wayland-1
  '';

  start-sway-service = pkgs.writeShellScript "start-sway" ''
    unset WAYLAND_DISPLAY
    exec ${pkgs.sway}/bin/sway
  '';

  start-waybar = pkgs.writeShellScript "start-waybar" ''
    ${get-swaysock}
    ${pkgs.waybar}/bin/waybar
  '';

  start-kanshi = pkgs.writeShellScript "start-kanshi" ''
    ${get-swaysock}
    ${pkgs.kanshi}/bin/kanshi
  '';

  get-random-bg-file = pkgs.writeScriptBin "get-random-bg-file" ''
    #!${pkgs.zsh}/bin/zsh
    FILE=(~/wallpapers/*.jpg(Noe{'REPLY=$RANDOM,$RANDOM'}[1,1]))
    echo "$FILE"
  '';

  set-random-bg = pkgs.writeScript "set-random-bg" ''
    #!${pkgs.zsh}/bin/zsh
    ${get-swaysock}
    ${pkgs.sway}/bin/swaymsg 'output "*" background '$(${get-random-bg-file}/bin/get-random-bg-file)' fill'
  '';

  swaylock-do-lock = pkgs.writeScript "swaylock-do-lock" ''
    #!${pkgs.zsh}/bin/zsh
    ${get-swaysock}
    ${pkgs.swaylock}/bin/swaylock -f -i "$(${get-random-bg-file}/bin/get-random-bg-file)" -s fill
  '';

  sway-dpms = pkgs.writeScriptBin "sway-dpms" ''
    #!${pkgs.zsh}/bin/zsh
    [[ -n "''${1}" ]] || exit 1
    ${get-swaysock}
    ${pkgs.sway}/bin/swaymsg "output * dpms ''${1}"
  '';

  vol = let
    notebook-sink = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  in pkgs.writeScriptBin "vol" ''
    #!${pkgs.zsh}/bin/zsh
    case "''${1}" in
      up)
        ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute "${notebook-sink}" 0
        ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume "${notebook-sink}" +2dB
        ;;
      down)
        ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume "${notebook-sink}" -2dB
        ;;
      mute)
        ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute "${notebook-sink}" 1
        ;;
    esac
  '';

  open-tmux = session: pkgs.writeShellScript "open-tmux" ''
    if ${pkgs.tmux}/bin/tmux has-session -t ${session}; then
      if [ "$1" == "-e" ]; then
        exec ${pkgs.tmux}/bin/tmux new-session -t ${session} \; set-option destroy-unattached on
      else
        exec ${pkgs.tmux}/bin/tmux new-session -t ${session} \; set-option destroy-unattached on \; new-window
      fi
    else
      exec ${pkgs.tmux}/bin/tmux new-session -t ${session} \; set-option destroy-unattached off
    fi
  '';

  open-fzf = pkgs.writeShellScript "open-fzf" ''
    SESSION_NAME=fzf

    if ! ${pkgs.tmux}/bin/tmux has-session -t $SESSION_NAME; then
      ${pkgs.tmux}/bin/tmux new-session -d -s $SESSION_NAME
    fi

    ${pkgs.tmux}/bin/tmux send-keys -t $SESSION_NAME " $*" ENTER
    exec ${pkgs.tmux}/bin/tmux attach-session -t $SESSION_NAME
  '';

  fzf-run = pkgs.writeScript "fzf-run" (builtins.replaceStrings
    [ "@zsh@" "@awk@" "@fzf@" "@find@" "@tmux@" ]
    [ "${pkgs.zsh}/bin/zsh" "${pkgs.gawk}/bin/awk" "${pkgs.fzf}/bin/fzf" "${pkgs.findutils}/bin/find" "${pkgs.tmux}/bin/tmux" ]
    (builtins.readFile ./fzf/fzf-run)
  );

  fzf-pdf = pkgs.writeScript "fzf-pdf" (builtins.replaceStrings
    [ "@zsh@" "@tmux@" "@rg@" "@fzf@" "@tr@" "@pdftotext@" "@grep@" "@zathura@" ]
    [ "${pkgs.zsh}/bin/zsh" "${pkgs.tmux}/bin/tmux" "${pkgs.ripgrep}/bin/rg" "${pkgs.fzf}/bin/fzf" "${pkgs.coreutils}/bin/tr" "${pkgs.poppler_utils}/bin/pdftotext" "${pkgs.gnugrep}/bin/grep" "${config.zathura.pkg}/bin/zathura" ]
    (builtins.readFile ./fzf/fzf-pdf)
  );

  fzf-paper-candidates = pkgs.writeScript "fzf-paper-candidates" (builtins.replaceStrings
    [ "@b2sum@" "@cut@" "@exiftool@" "@jq@" "@mkdir@" "@pdftotext@" "@rg@" "@rm@" "@sort@" "@stat@" "@tee@" "@tr@" "@xargs@" "@zsh@" ]
    [ "${pkgs.coreutils}/bin/b2sum" "${pkgs.coreutils}/bin/cut" "${pkgs.exiftool}/bin/exiftool" "${pkgs.jq}/bin/jq" "${pkgs.coreutils}/bin/mkdir" "${pkgs.poppler_utils}/bin/pdftotext" "${pkgs.ripgrep}/bin/rg" "${pkgs.coreutils}/bin/rm" "${pkgs.coreutils}/bin/sort" "${pkgs.coreutils}/bin/stat" "${pkgs.coreutils}/bin/tee" "${pkgs.coreutils}/bin/tr" "${pkgs.findutils}/bin/xargs" "${pkgs.zsh}/bin/zsh" ]
    (builtins.readFile ./fzf/fzf-paper-candidates)
  );

  fzf-paper = pkgs.writeScript "fzf-paper" (builtins.replaceStrings
    [ "@awk@" "@b2sum@" "@cut@" "@fzf@" "@fzf-paper-candidates@" "@grep@" "@stat@" "@tmux@" "@tr@" "@zathura@"  "@zsh@" ]
    [ "${pkgs.gawk}/bin/awk" "${pkgs.coreutils}/bin/b2sum" "${pkgs.coreutils}/bin/cut" "${pkgs.fzf}/bin/fzf" "${fzf-paper-candidates}" "${pkgs.gnugrep}/bin/grep" "${pkgs.coreutils}/bin/stat" "${pkgs.tmux}/bin/tmux" "${pkgs.coreutils}/bin/tr" "${config.zathura.pkg}/bin/zathura" "${pkgs.zsh}/bin/zsh" ]
    (builtins.readFile ./fzf/fzf-paper)
  );

  update-fzf-paper = pkgs.writeShellScriptBin "update-fzf-paper" ''
    ${fzf-paper-candidates} $HOME/.local/cache/pdftotext
  '';

  fzf-ff-url-candidates = pkgs.writeScript "fzf-ff-url-candidates" (builtins.replaceStrings
    [ "@zsh@" "@sqlite3@" "@cat@" ]
    [ "${pkgs.zsh}/bin/zsh" "${pkgs.sqlite}/bin/sqlite3" "${pkgs.coreutils}/bin/cat" ]
    (builtins.readFile ./fzf/fzf-ff-url-candidates)
  );

  fzf-ff-url = pkgs.writeScript "fzf-ff-url" (builtins.replaceStrings
    [ "@zsh@" "@fzf-ff-url-candidates@" "@awk@" "@fzf@" "@grep@" "@pgrep@" "@tmux@" "@firefox-unwrapped@" "@firefox@" ]
    [ "${pkgs.zsh}/bin/zsh" "${fzf-ff-url-candidates}" "${pkgs.gawk}/bin/awk" "${pkgs.fzf}/bin/fzf" "${pkgs.gnugrep}/bin/grep"  "${pkgs.procps}/bin/pgrep" "${pkgs.tmux}/bin/tmux" "${config.browser.firefox-unwrapped}/bin/firefox" "${config.browser.firefox}/bin/firefox" ]
    (builtins.readFile ./fzf/fzf-ff-url)
  );

  # fzf-chrome-url-candidates = pkgs.writeScript "fzf-chrome-url-candidates" (builtins.replaceStrings
  #   [ "@zsh@" "@sqlite3@" "@cat@" "@jq@" ]
  #   [ "${pkgs.zsh}/bin/zsh" "${pkgs.sqlite}/bin/sqlite3" "${pkgs.coreutils}/bin/cat" "${pkgs.jq}/bin/jq" ]
  #   (builtins.readFile ./fzf/fzf-chrome-url-candidates)
  # );

  # fzf-chrome-url = pkgs.writeScript "fzf-chrome-url" (builtins.replaceStrings
  #   [ "@zsh@" "@fzf-chrome-url-candidates@" "@awk@" "@fzf@" "@grep@" "@pgrep@" "@tmux@" "@chromium-unwrapped@" "@chromium-browser@" ]
  #   [ "${pkgs.zsh}/bin/zsh" "${fzf-chrome-url-candidates}" "${pkgs.gawk}/bin/awk" "${pkgs.fzf}/bin/fzf" "${pkgs.gnugrep}/bin/grep"  "${pkgs.procps}/bin/pgrep" "${pkgs.tmux}/bin/tmux" "${config.browser.chromium-unwrapped}/bin/chromium-browser"  "${config.browser.chromium}/bin/chromium" ]
  #   (builtins.readFile ./fzf/fzf-chrome-url)
  # );

  fzf-pass = pkgs.writeScript "fzf-pass" (builtins.replaceStrings
    [ "@zsh@" "@tmux@" "@pass@" "@head@" "@wl-copy@" "@fzf@" ]
    [ "${pkgs.zsh}/bin/zsh" "${pkgs.tmux}/bin/tmux" "${pkgs.pass}/bin/pass" "${pkgs.coreutils}/bin/head" "${pkgs.wl-clipboard}/bin/wl-copy" "${pkgs.fzf}/bin/fzf" ]
    (builtins.readFile ./fzf/fzf-pass)
  );

  fzf-emoji = let
    inherit (flake.inputs.emoji-fzf.packages.${pkgs.stdenv.system}) emoji-fzf;
  in pkgs.writeScript "fzf-emoji" ''
    function die() {
      ${pkgs.tmux}/bin/tmux detach
      exit $1
    }

    emoji=$(${emoji-fzf}/bin/emoji-fzf preview \
      | ${pkgs.fzf}/bin/fzf -e -d $'\t' --reverse --preview-window right:75% \
        --preview '${emoji-fzf}/bin/emoji-fzf get < {f1}' \
      | ${pkgs.coreutils}/bin/cut -d $'\t' -f 1)

    [[ -n "''${emoji}" ]] || die 1
    sel=$(${emoji-fzf}/bin/emoji-fzf get <<<"''${emoji}")
    ${pkgs.wl-clipboard}/bin/wl-copy -n <<<"''${sel}"
    die 0
  '';

  mpv-scripts = config.mpv.scripts;

  colors = {
    bg = "#103c48";
    black = "#184956";
    br_black = "#2d5b69";

    white = "#72898f";
    fg = "#adbcbc";
    br_white = "#cad8d9";

    red = "#fa5750";
    green = "#75b938";
    yellow = "#dbb32d";
    blue = "#4695f7";
    magenta = "#f275be";
    cyan = "#41c7b9";
    orange = "#ed8649";
    violet = "#af88eb";

    br_red = "#ff665c";
    br_green = "#84c747";
    br_yellow = "#ebc13d";
    br_blue = "#58a3ff";
    br_magenta = "#ff84cd";
    br_cyan = "#53d6c7";
    br_orange = "#fd9456";
    br_violet = "#bd96fa";
  };
in lib.mkMerge [{
  home.packages = with pkgs; [
    grim wl-clipboard slurp brightnessctl
    libappindicator
    mako
    start-sway
    get-random-bg-file sway-dpms
    vol
    update-fzf-paper
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    WAYLAND_DISPLAY = "wayland-1";
  };

  systemd.user.sockets.dbus = {
    Unit = {
      Description = "D-Bus User Message Bus Socket";
    };
    Socket = {
      ListenStream = "%t/bus";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
      Also = [ "dbus.service" ];
    };
  };
  systemd.user.services.dbus = {
    Unit = {
      Description = "D-Bus User Message Bus";
      Requires = [ "dbus.socket" ];
    };
    Service = {
      ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation";
      ExecReload = "${pkgs.dbus}/bin/dbus-send --print-reply --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
    };
    Install = {
      Also = [ "dbus.socket" ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway.override {
      withGtkWrapper = true;
    };
    systemdIntegration = false;
    config = let
      mod = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      scratch-terminal = "${pkgs.alacritty}/bin/alacritty";
      ws = lib.genAttrs (map (i: "${builtins.toString i}") (lib.range 1 9)) (n: n) // {
        "0" = "10";
        "1" = "web";
        "grave" = "video";
        "t" = "chat";
        "m" = "mail";
        "e" = "edit";
        "z" = "zoom";
      };
      switch-ws-keys = lib.mapAttrs' (k: n: lib.nameValuePair "${mod}+${k}" "workspace ${n}") ws;
      move-ws-keys = lib.mapAttrs' (k: n: lib.nameValuePair "${mod}+Shift+${k}" "move container to workspace ${n}") ws;
    in {
      fonts = {
        names = [ "PragmataPro" ];
        style = "Liga";
        size = 11.0;
      };
      focus = {
        newWindow = "none";
        followMouse = false;
        forceWrapping = true;
        mouseWarping = true;
      };
      modifier = mod;
      workspaceLayout = "tabbed";
      workspaceAutoBackAndForth = true;
      window = {
        titlebar = false;
        commands = [
          {
            command = "move window to scratchpad, scratchpad show, resize set 1536 864, move position center";
            criteria = {
              title = "^scratchpad";
            };
          }
          {
            command = "mark \"mpv\", move --no-auto-back-and-forth container to workspace video";
            criteria = {
              app_id = "mpv";
            };
          }
        ];
      };
      colors = {
        focused = {
          border = colors.blue;
          background = colors.blue;
          text = colors.black;
          indicator = colors.green;
          childBorder = colors.blue;
        };
        focusedInactive = {
          border = colors.cyan;
          background = colors.cyan;
          text = colors.black;
          indicator = colors.violet;
          childBorder = colors.cyan;
        };
        unfocused = {
          border = colors.black;
          background = colors.black;
          text = colors.fg;
          indicator = colors.white;
          childBorder = colors.white;
        };
      };
      keybindings = switch-ws-keys // move-ws-keys // {
        "${mod}+Shift+q" = "kill";
        "${mod}+f" = "fullscreen";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+comma" = "layout default";
        "${mod}+period" = "layout tabbed";
        "${mod}+slash" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";
        "${mod}+Shift+a" = "focus child";

        "${mod}+b" = "border toggle";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+x" = "exit";

        "${mod}+Return" = "exec ${terminal} -e ${open-tmux "persistent"}";
        "${mod}+Shift+Return" = "exec ${terminal} -e ${open-tmux "persistent"} -e";
        "${mod}+s" = "exec ${terminal} -e ${open-tmux "kak"}";
        "${mod}+Shift+s" = "exec ${terminal} -e ${open-tmux "kak"} -e";

        "${mod}+d" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-run}";
        "${mod}+Shift+p" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-pass}";
        "${mod}+q" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-ff-url}";
        "${mod}+o" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-pdf}";
        "${mod}+Shift+o" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-paper}";
        "${mod}+u" = "exec ${scratch-terminal} --title \"scratchpad-fzf\" -e ${open-fzf} ${fzf-emoji}";

        "XF86AudioMute" = "exec ${vol}/bin/vol mute";
        "XF86AudioLowerVolume" = "exec ${vol}/bin/vol down";
        "XF86AudioRaiseVolume" = "exec ${vol}/bin/vol up";

        "XF86AudioPause" = "exec ${mpv-scripts}/bin/mpv-pause";
        "XF86AudioPlay" = "exec ${mpv-scripts}/bin/mpv-pause-toggle";
        "XF86AudioNext" = "exec ${mpv-scripts}/bin/mpv-next";
        "XF86AudioPrev" = "exec ${mpv-scripts}/bin/mpv-prev";

        "XF86Sleep" = "exec ${pkgs.systemd}/bin/loginctl lock-session";

        "Print" = "exec ${pkgs.obs-cli}/bin/obs-cli toggle-mute Mic/Aux";

        "${mod}+Ctrl+j" = "move workspace to output down";
        "${mod}+Ctrl+k" = "move workspace to output up";
        "${mod}+Ctrl+l" = "move workspace to output right";
        "${mod}+Ctrl+h" = "move workspace to output left";

        "${mod}+Shift+w" = "mode \"resize\"";

        "${mod}+v" = "[con_mark=\"mpv\"] focus";
      };

      modes = {
        "resize" = {
          "h" = "resize shrink width 10 px or 10ppt";
          "j" = "resize grow height 10 px or 10ppt";
          "k" = "resize shrink height 10 px or 10ppt";
          "l" = "resize grow width 10 px or 10ppt";
          "s" = "split v; mode \"default\"";
          "v" = "split h; mode \"default\"";
          "Escape" = "mode \"default\"";
          "Return" = "mode \"default\"";
        };
      };

      input = {
        "2:14:ETPS/2_Elantech_Touchpad" = {
          accel_profile = "adaptive";
          pointer_accel = "1";
          tap = "enabled";
          drag_lock = "enabled";
          natural_scroll = "enabled";
        };
        "*" = {
          xkb_options = "compose:ralt";
        };
      };
      bars = [ ];

      gaps = {
        smartGaps = true;
        smartBorders = "on";
        inner = 5;
        outer = 0;
      };
    };
    extraConfig = ''
      hide_edge_borders --i3 none
      no_focus [tiling]
      seat * hide_cursor 5000

      focus_wrapping workspace
    '';
  };

  systemd.user.services.sway = {
    Unit = {
      Description = "Sway - Wayland window manager";
      Documentation = [ "man:sway(5)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${start-sway-service}";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      RestartSec = 5;
      Restart = "always";
    };
  };
  xdg.configFile."mako/config".text = ''
    font=PragmataPro
    background-color=${colors.bg}
    text-color=${colors.fg}
    icons=0
    format=<b>%s</b>\n%b
    default-timeout=6000
    border-color=${colors.green}
    border-radius=10

    [urgency=low]
    border-color=${colors.cyan}
    default-timeout=4000

    [urgency=normal]
    border-color=${colors.green}
    default-timeout=6000

    [urgency=high]
    border-color=${colors.red}
    default-timeout=8000
  '';

  # systemd.user.services.clipman = {
  #   Unit = {
  #     Description = "Clipman clipboard manager";
  #     PartOf = [ "graphical-session.target" ];
  #   };
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/.local/share";
  #     ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --max-items=1";
  #     RestartSec = 5;
  #     Restart = "always";
  #   };
  # };

  systemd.user.services.swayidle = let
    swayidle-cmd = "${pkgs.swayidle}/bin/swayidle -w"
      + " lock '${swaylock-do-lock}'"
      + " timeout 600 '${swaylock-do-lock}'"
      + " timeout 1200 '${sway-dpms}/bin/sway-dpms off'"
      + " resume '${sway-dpms}/bin/sway-dpms on'"
      + " before-sleep '${swaylock-do-lock}'";
  in {
    Unit = {
      Description = "Idle manager for sway";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = swayidle-cmd;
      RestartSec = 5;
      Restart = "always";
    };
  };

  systemd.user.services.kanshi = {
    Unit = {
      Description = "Kanshi dynamic display configuration";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${start-kanshi}";
      RestartSec = 5;
      Restart = "always";
    };
  };

  xdg.configFile."kanshi/config".text = ''
    profile nomad {
      output eDP-1 enable mode 1920x1080 position 0,0
    }
    profile multi-dock {
      output "Unknown ASUS PB27U 0x0000388B" enable mode 2560x1440 position 0,0
      output "Samsung Electric Company S24E650 0x00005F51" enable mode 1920x1080 position 0,3000
      output eDP-1 disable
    }
  '';

  systemd.user.services.waybar = {
    Unit = {
      Description = "Wayland bar for Sway and Wlroots based compositors";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${start-waybar}";
      RestartSec = 5;
      Restart = "always";
    };
  };

  xdg.configFile."waybar/config".text = ''
    {
      "layer": "top",
      "modules-left": ["idle_inhibitor", "sway/workspaces", "sway/mode"],
      "modules-center": ["sway/window"],
      "modules-right": ["network", "pulseaudio", "backlight", "battery", "cpu", "clock", "tray"],
      "sway/workspaces": {
        "disable-scroll": true
      },
      "sway/window": {
        "max-length": 80
      },
      "battery": {
        "states": {
            "full": 100,
            "good": 95,
            "warning": 30,
            "critical": 15
        },
        "full-at": 100,
        "format": "{time} {capacity}%{icon}",
        "format-charging": "{time} {capacity}%",
        "format-full": "{icon}",
        "format-icons": [ "", "", "", "", "", "", "", "", "", "" ],
        "format-time": "{H}:{M:02}"
      },
      "clock": {
        "format": "{:%d-%m %H:%M %Z}"
      },
      "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
          "activated": "",
          "deactivated": ""
        }
      },
      "pulseaudio": {
        "format": "{volume}%{icon} {format_source}",
        "format-bluetooth": "{volume}%{icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}%",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "default": [ "", "", "" ]
        },
        "on-click": "${pkgs.pavucontrol}/bin/pavucontrol"
      },
      "backlight": {
        "device": "intel_backlight",
        "on-scroll-up": "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s +1%",
        "on-scroll-down": "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 1%-",
        "on-click": "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 1%",
        "format": "{percent}%"
      },
      "network": {
           "format": "{ifname}",
           "format-wifi": "{essid}",
           "format-ethernet": "",
           "format-disconnected": "", //An empty format will hide the module.
           "tooltip-format": "{ifname}",
           "tooltip-format-wifi": "{ipaddr}/{cidr} {essid} ({signalStrength}%)",
           "tooltip-format-ethernet": "{ipaddr}/{cidr} {ifname}",
           "tooltip-format-disconnected": "Disconnected",
               "max-length": 50
      },
      "cpu": {
        "format": "{usage}%"
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
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

    #workspaces button.focused {
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

  systemd.user.services.random-background = {
    Unit = {
      Description = "Set random desktop background for sway";
      PartOf = [ "graphical-session.target" ];
      After = [ "sway.service" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${set-random-bg}";
      IOSchedulingClass = "idle";
    };
  };
  systemd.user.timers.random-background = {
    Unit = {
      Description = "Set random desktop background for sway";
    };
    Timer = {
      OnUnitActiveSec = "1h";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    font = {
      package = null;
      name = "PragmataPro 12";
    };
  };
} (lib.mkIf (builtins.elem "ibus" nixos.system.profiles) {
})]
