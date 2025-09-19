{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    profiles.bluetooth
    profiles.fonts
    profiles.gnome-keyring
    profiles.regreet
    profiles.virtualisation
    profiles.pipewire
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
