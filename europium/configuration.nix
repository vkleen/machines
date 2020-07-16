{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
      ./networking.nix
      ./matrix.nix

      ../seaborgium/secrets.nix
    ];

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-overlays=${./overlays}"
    ];

    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "bohrium.1:4jkGCWrIChiDoTjSK4+tErEwtN6kvbkp5uO1BrAYguE="
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (import ../cache-keys/aws-vkleen-nix-cache-1.public)
    ];
  };

  nix.useSandbox = true;
  nix.trustedUsers = [ "root" ];

  time.timeZone = "UTC";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ ];
  networking.hostId = "f8a1f27f";
  environment.etc."machine-id".text = "f8a1f27fe211912366eb4b536c533419";

  environment.systemPackages = with pkgs; [
    wget vim mosh tmux
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  security.sudo.configFile =
  ''
    Defaults:root,%wheel env_keep+=TERMINFO_DIRS
    Defaults:root,%wheel env_keep+=TERMINFO
    Defaults env_keep+=SSH_AUTH_SOCK
    Defaults !lecture,insults,rootpw

    root        ALL=(ALL) SETENV: ALL
    %wheel      ALL=(ALL:ALL) SETENV: ALL
  '';

  services.ntp.enable = false;
  services.chrony = {
    enable = true;
    initstepslew = {
      enabled = true;
      threshold = 1000;
    };
  };

  services.udisks2.enable = false;
  services.xserver.enable = false;
  hardware.opengl.enable = false;
}
