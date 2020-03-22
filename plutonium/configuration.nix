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
    ];

    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (import ../cache-keys/aws-vkleen-nix-cache-1.public)
    ];
  };

  nix.useSandbox = true;
  nix.trustedUsers = [ "root" ];

  time.timeZone = "UTC";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ ];
  networking.hostId = "d034b380";
  environment.etc."machine-id".text = "d034b380c72ffdad1704dc935c5b57d0";

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
  services.chrony.enable = true;
  services.chrony.servers = [
    "0.north-america.pool.ntp.org"
    "1.north-america.pool.ntp.org"
    "2.north-america.pool.ntp.org"
    "3.north-america.pool.ntp.org"
  ];
  services.chrony.extraConfig = ''
    bindcmdaddress 127.0.0.1
    bindcmdaddress ::1
    port 0
    rtcsync
  '';

  services.udisks2.enable = false;
  services.xserver.enable = false;
  hardware.opengl.enable = false;
}
