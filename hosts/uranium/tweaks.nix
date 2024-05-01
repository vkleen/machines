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
      rocmPackages.clr.icd
    ];
  };

  nix.settings.keep-outputs = true;

  nixpkgs.config.rocmSupport = true;

  environment.systemPackages = [
    pkgs.sunshine
  ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
}
