{ config, pkgs, nixos, lib, flake, ... }:
let
  khal-config = ''
    [calendars]
    [[calendars]]
    path = ${config.home.homeDirectory}/.calendar/*
    type = discover
    [default]
    highlight_event_days = True
    show_all_days = True
    timedelta = 14d
    [locale]
    default_timezone = Etc/UTC
    local_timezone = Etc/UTC
    firstweekday = 0
    weeknumbers = left
    timeformat = %H:%M
    dateformat = %d.%m.
    longdateformat = %Y-%m-%d
    datetimeformat = %d.%m. %H:%M
    longdatetimeformat = %Y-%m-%d %H:%M
  '';
in {
  home.packages = [ pkgs.khal ];
  xdg.configFile = {
    "khal/config".text = khal-config;
  };
}
