{ config, pkgs, lib, ... }:

{
  services.kresd.enable = true;
  networking.nameservers = [ "127.0.0.1" ];
}
