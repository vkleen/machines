flake:
{ config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  nix.package = pkgs.nixFlakes;
  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      dnsutils
      fd
      git
      gptfdisk
      iputils
      jq
      ripgrep
      utillinux
      sudo
    ];
  };

  nix = {
    useSandbox = true;
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

  security = {
    hideProcessInformation = false;
    protectKernelImage = true;
  };

  users.mutableUsers = false;

  boot.cleanTmpDir = true;

  time.timeZone = "UTC";

  security.sudo.configFile = ''
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
}
