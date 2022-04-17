{ config, flake, lib, pkgs, ... }:
let
  greeter-sway-config = pkgs.writeText "sway-config" ''
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; ${pkgs.sway}/bin/swaymsg exit"
    bindsym Mod4+shift+e exec ${pkgs.sway}/bin/swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Power off' '${pkgs.systemd}/bin/systemctl poweroff' \
      -b 'Reboot' '${pkgs.systemd}/bin/systemctl reboot'
  '';
in {
  environment.etc = {
    "greetd/environments".text = ''
      ${pkgs.sway}/bin/sway
      ${pkgs.zsh}/bin/zsh
    '';
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.sway}/bin/sway";
        command = "${pkgs.sway}/bin/sway --config ${greeter-sway-config}";
      };
    };
  };
}
