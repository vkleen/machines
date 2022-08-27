{ config, pkgs, nixos, lib, flake, ... }:
let
  todoman-config = ''
    path = "${config.home.homeDirectory}/.calendar/*"
    date_format = "%Y-%m-%d"
    time_format = "%H:%M"
    default_list = "Personal"
    default_due = 0
  '';
in {
  home.packages = [ pkgs.todoman ];
  xdg.configFile = {
    "todoman/config.py".text = todoman-config;
  };
}
