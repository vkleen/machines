{ pkgs, lib, ... }:
{
  services.fwupd.enable = lib.mkForce false;

  programs.hyprland.enable = lib.mkForce false;
  programs.sway.enable = true;
  services.greetd.enable = lib.mkForce false;

  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  nix.settings.keep-outputs = true;

  environment.systemPackages = [
    pkgs.sunshine
  ];
}
