{ config, pkgs, lib, ... }:

{
  services.kresd.enable = false;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
}
