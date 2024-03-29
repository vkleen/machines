{ config, pkgs, nixos, lib, flake, ... }:
let
  dotDir = "${config.home.homeDirectory}/.vdirsyncer";
  listToValue = xs: "[${lib.concatMapStringsSep ", " (x: if lib.isList x then listToValue x else "\"${x}\"") xs}]";
  vdirsyncer-config = (pkgs.formats.ini { inherit listToValue; }).generate "vdirsyncer-config" (lib.mapAttrsRecursive
  (_: v: if lib.isString v then "\"${v}\"" else v)
  {
    general = {
      status_path = "${dotDir}/status/";
    };
    "pair radicale" = {
      a = "calendar_local";
      b = "radicale_calendars";
      collections = [
        ["personal" "personal" "cffc963f-7bbc-4d92-b073-6bc99d5b71ef"]
        ["tweag" "tweag" "8f44a71f-8eeb-40cb-b5a9-8ad54e76ae43"]
        ["aviation" "aviation" "81551ab6-0e80-4e26-8642-1152764dd3fe"]
        ["ude" "ude" "e6ecc05b-a76d-476b-bec9-280f2f6c0944"]
        ["tweag-todo" "tweag-todo" "2c8784ea-687d-4b84-b44f-74fd6fa00f50"]
      ];
      metadata = ["color" "displayname"];
      conflict_resolution = ["command" "vimdiff"];
    };
    "pair tweag_pair" = {
      a = "tweag";
      b = "calendar_local";
      collections = [
        ["tweag" "viktor.kleen@tweag.io" "tweag" ]
      ];
    };
    "storage calendar_local" = {
      type = "filesystem";
      path = "${config.home.homeDirectory}/.calendar/";
      fileext = ".ics";
    };
    "storage radicale_calendars" = {
      type = "caldav";
      url = "https://radicale.as210286.net/";
      username = "vkleen";
      "password.fetch" = ["command" "pass" "radicale/vkleen"];
      auth_cert = "/run/agenix/radicale/client_cert.pem";
    };
    "storage tweag" = {
      type = "google_calendar";
      read_only = true;
      token_file = "${config.home.homeDirectory}/.vdirsyncer/google_token";
      "client_id.fetch" = ["command" "pass" "vdirsyncer/client_id"];
      "client_secret.fetch" = ["command" "pass" "vdirsyncer/client_secret"];
    };
  });
in {
  home.packages = [ pkgs.vdirsyncer ];
  xdg.configFile = {
    "vdirsyncer/config".source = vdirsyncer-config;
  };
}
