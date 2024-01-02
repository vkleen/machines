{ pkgs, ... }:
{
  services.interception-tools =
    let
      dual-function-yaml = (pkgs.formats.yaml { }).generate "dual-function.yaml" {
        MAPPINGS = [
          {
            KEY = "KEY_LEFTCTRL";
            TAP = "KEY_ESC";
            HOLD = "KEY_LEFTCTRL";
          }
          {
            KEY = "KEY_CAPSLOCK";
            TAP = "KEY_ESC";
            HOLD = "KEY_LEFTCTRL";
          }
        ];
      };
    in
    {
      enable = true;
      plugins = with pkgs.interception-tools-plugins; [ dual-function-keys caps2esc ];
      udevmonConfig = builtins.toJSON [
        {
          JOB = "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c ${dual-function-yaml} | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE";
          DEVICE = {
            LINK = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
            EVENTS = {
              EV_KEY = [ "KEY_LEFTCTRL" "KEY_CAPSLOCK" ];
            };
          };
        }
      ];
    };
}
