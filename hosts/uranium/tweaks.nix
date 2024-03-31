{ pkgs, lib, ... }:
{
  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];

  programs.hyprland.enable = lib.mkForce false;
  programs.sway.enable = true;
  services.greetd.enable = lib.mkForce false;

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
