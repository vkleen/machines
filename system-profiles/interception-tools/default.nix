{ config, pkgs, ... }:
let
  dual-function-yaml = pkgs.writeText "dual-function.yaml" ''
    MAPPINGS:
      - KEY: KEY_LEFTCTRL
        TAP: KEY_ESC
        HOLD: KEY_LEFTCTRL
      - KEY: KEY_CAPSLOCK
        TAP: KEY_ESC
        HOLD: KEY_LEFTCTRL
  '';
in {
  services.interception-tools = {
    enable = true;
    plugins = with pkgs.interception-tools-plugins; [ dual-function-keys caps2esc ];
    udevmonConfig = ''
      - JOB: "intercept -g $DEVNODE | dual-function-keys -c ${dual-function-yaml} | uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_LEFTCTRL, KEY_CAPSLOCK]
    '';
  };
}
