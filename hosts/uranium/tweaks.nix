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
      # rocmPackages_5.clr.icd
    ];
  };

  nix.settings.keep-outputs = true;

  nixpkgs.config.rocmSupport = false;

  environment.systemPackages = [
    pkgs.sunshine
  ];

  boot.binfmt = {
    emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  programs.nix-ld.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", ATTRS{serial}=="DQ00ELQ3", SYMLINK+="ttycx2"
  '';
}
