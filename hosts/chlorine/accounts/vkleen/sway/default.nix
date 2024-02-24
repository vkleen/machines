{ pkgs, lib, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config =
      let
        mod = "Mod1";
        ws = lib.pipe (lib.range 1 9) [
          (builtins.map builtins.toString)
          (lib.flip lib.foreach (n: {
            "${mod}+${n}" = "workspace ${n}";
            "${mod}+Shift+${n}" = "move container to workspace ${n}";
          }))
        ];
      in
      {
        modifier = mod;
        workspaceLayout = "tabbed";
        workspaceAutoBackAndForth = true;
        keybindings = ws // {
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

          "${mod}+Return" = "exec ${lib.getExe pkgs.foot}";
        };
        output = {
          "HEADLESS-1" = {
            mode = "1920x1080@60Hz";
          };
        };
      };
  };
}
