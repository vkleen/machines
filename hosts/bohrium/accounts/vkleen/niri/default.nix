{ lib, pkgs, inputs, config, ... }:
let
  niri = config.programs.niri.package;

  terminal = lib.getExe pkgs.alacritty;

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
        niri
      ];
      text = ''
        workspaces="$(niri msg -j workspaces)"
        windows="$(niri msg -j windows)"

        current_id="$(echo "$windows" | gojq -r '.[] | select(.is_focused) | .id')"

        # shellcheck disable=SC2016
        window="$(echo "$windows" |
          gojq --argjson workspaces "$workspaces" -r '.[] | .workspace_id as $workspace_id | .workspace = ($workspaces[] | select(.id == $workspace_id) | if .name then .name else .id end) | "\(.title)\t\(.workspace)\t\(.id)"' |
          fuzzel --log-level=warning --dmenu)"

        new_id="$(echo "$window" | awk -F $'\t' '{print $3}')"

        if [[ "$new_id" = "$current_id" ]]; then
          exit 0
        fi

        niri msg action focus-window --id "$new_id" 
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
        sioyek
      ];
      text = ''
        prefix=(~/dl ~/books)
        function _do_select() {
          rg -0 --files --sortr=modified --iglob '*.{pdf,djvu}' "''${prefix[@]}" \
            | fuzzel --log-level=warning --dmenu0
        }

        file=$(_do_select)
        exec sioyek "$file"
      '';
    };
in
{
  imports = lib.findModulesList ./.;
  config = {
    home.packages = with pkgs; [
      grim
      wl-clipboard
      slurp
    ];

    programs.niri.settings = {
      prefer-no-csd = true;
      screenshot-path = "${config.home.homeDirectory}/Pictures/niri";

      input = {
        keyboard.xkb = {
          layout = "us";
          options = "compose:ralt";
        };
        touchpad = {
          natural-scroll = true;
          accel-speed = 0.5;
        };

        workspace-auto-back-and-forth = true;
        focus-follows-mouse.enable = false;
        warp-mouse-to-focus = true;
      };

      spawn-at-startup = [
        { command = [ (lib.getExe pkgs.xwayland-satellite-unstable) ]; }
      ];

      environment = {
        DISPLAY = ":0";
      };

      outputs = {
        "eDP-1" = {
          position = { x = 0; y = 0; };
          scale = 1;
        };
        "Samsung Electric Company S24E650 0x5A5A5551" = {
          position = { x = 2256; y = 0; };
          scale = 1;
        };
        "ASUSTek COMPUTER INC ASUS PB27U 0x0000388B" = {
          position = { x = 2256 + 1920; y = 0; };
          scale = 1;
        };
      };

      layout = {
        gaps = 8;
        preset-column-widths = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 8. / 9.; }
        ];
        default-column-width.proportion = 1. / 2.;
        preset-window-heights = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
        ];

        border.width = 1;
        center-focused-column = "on-overflow";
      };

      cursor.hide-when-typing = true;

      hotkey-overlay.skip-at-startup = true;

      animations = {
        shaders.window-resize = ''
          vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
            vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

            vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
            vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

            // We can crop if the current window size is smaller than the next window
            // size. One way to tell is by comparing to 1.0 the X and Y scaling
            // coefficients in the current-to-next transformation matrix.
            bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
            bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

            vec3 coords = coords_stretch;
            if (can_crop_by_x)
              coords.x = coords_crop.x;
            if (can_crop_by_y)
              coords.y = coords_crop.y;

            vec4 color = texture2D(niri_tex_next, coords.st);

            // However, when we crop, we also want to crop out anything outside the
            // current geometry. This is because the area of the shader is unspecified
            // and usually bigger than the current geometry, so if we don't fill pixels
            // outside with transparency, the texture will leak out.
            //
            // When stretching, this is not an issue because the area outside will
            // correspond to client-side decoration shadows, which are already supposed
            // to be outside.
            if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
              color = vec4(0.0);
            if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
              color = vec4(0.0);

            return color;
          }
        '';
      };

      workspaces."11".name = "browser";
      workspaces."12".name = "term";
      workspaces."13".name = "chat";
      workspaces."14".name = "vid";
      workspaces."15".name = "mail";
      workspaces."16".name = "sys";

      window-rules = [
        (
          let
            allCorners = r: { bottom-left = r; bottom-right = r; top-left = r; top-right = r; };
          in
          {
            geometry-corner-radius = allCorners 10.;
            clip-to-geometry = true;
            open-focused = false;
          }
        )
        {
          matches = [{ app-id = "^Rofi$"; }];
          open-floating = true;
          open-focused = true;
        }
      ];

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn terminal "-e" "${open-tmux "persistent"}";
        "Mod+Shift+Return".action = spawn terminal;

        "Mod+P".action = spawn (lib.getExe fuzzel-pdf);
        "Mod+Shift+P".action = spawn (lib.getExe fuzzel-pass);

        "Mod+W".action = spawn (lib.getExe switch-window);

        "Mod+Shift+Control+X".action = quit;

        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;

        "Mod+N".action = focus-column-left;
        "Mod+E".action = focus-window-down;
        "Mod+I".action = focus-window-up;
        "Mod+O".action = focus-column-right;

        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Shift+N".action = move-column-left;
        "Mod+Shift+E".action = move-window-down;
        "Mod+Shift+I".action = move-window-up;
        "Mod+Shift+O".action = move-column-right;

        "Mod+U".action = focus-workspace-down;
        "Mod+Y".action = focus-workspace-up;
        "Mod+Control+U".action = move-workspace-down;
        "Mod+Control+Y".action = move-workspace-up;
        "Mod+Shift+U".action = move-column-to-workspace-down;
        "Mod+Shift+Y".action = move-column-to-workspace-up;

        "Mod+Control+H".action = focus-workspace-up;
        "Mod+Control+L".action = focus-workspace-down;

        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+Shift+Control+H".action = move-workspace-to-monitor-left;
        "Mod+Shift+Control+J".action = move-workspace-to-monitor-down;
        "Mod+Shift+Control+K".action = move-workspace-to-monitor-up;
        "Mod+Shift+Control+L".action = move-workspace-to-monitor-right;

        "Mod+Shift+Control+N".action = move-workspace-to-monitor-left;
        "Mod+Shift+Control+E".action = move-workspace-to-monitor-down;
        "Mod+Shift+Control+I".action = move-workspace-to-monitor-up;
        "Mod+Shift+Control+O".action = move-workspace-to-monitor-right;

        "Mod+C".action = center-column;

        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        "Mod+Equal".action = switch-preset-column-width;

        "Mod+1".action = focus-workspace "browser";
        "Mod+2".action = focus-workspace "term";
        "Mod+grave".action = focus-workspace "vid";
        "Mod+T".action = focus-workspace "chat";

        "Mod+Space".action = switch-focus-between-floating-and-tiling;
        "Mod+Shift+Space".action = toggle-window-floating;

        "Mod+Shift+Q".action = close-window;
      };
    };
  };
}
