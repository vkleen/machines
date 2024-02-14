{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    base
    profiles.bluetooth
    profiles.fonts
    profiles.gnome-keyring
    profiles.hyprland
    profiles.tuigreet
    profiles.virtualisation
    trilby.profiles.pipewire
    trilby.profiles.plymouth
  ];
  config = {
    programs.dconf.enable = true;
    services.fwupd.enable = true;
    services.usbmuxd.enable = true;
    security.rtkit.enable = true;

    programs.gphoto2.enable = true;

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;
    };
  };
}
