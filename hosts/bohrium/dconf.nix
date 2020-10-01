{ config, pkgs, lib, ... }:

{
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
  ];
}
