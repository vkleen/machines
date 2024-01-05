{ pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd ${lib.getExe pkgs.hyprland}";
        user = "greeter";
      };
    };
  };
}
