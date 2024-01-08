{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    base
    trilby.profiles.pipewire
    trilby.profiles.plymouth
    trilby.profiles.virtualisation
    profiles.tuigreet
    profiles.gnome-keyring
    profiles.hyprland
    profiles.fonts
    profiles.bluetooth
  ];
  config = {
    programs.dconf.enable = true;
    services.fwupd.enable = true;
    services.usbmuxd.enable = true;
    security.rtkit.enable = true;

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;
    };
  };
}
