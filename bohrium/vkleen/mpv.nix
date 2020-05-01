{ pkgs, config, lib, nixos, ... }:
let
  mpv-socket = config.mpv.ipc-socket;
  start-mpv = pkgs.writeScriptBin "start-mpv" ''
    #!${pkgs.stdenv.shell}
    mpv --force-window --keep-open=yes --idle=yes --input-ipc-server=${mpv-socket}
  '';
  play = pkgs.writeScriptBin "play" ''
    #!${pkgs.stdenv.shell}
    URL=''${1}
    [[ -n "$URL" ]] || exit 1
    [[ -S "${mpv-socket}" ]] || exit 1

    echo '{ "command": ["loadfile", "'$URL'", "append-play"] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}"
  '';
  play-clip = pkgs.writeScriptBin "play-clip" ''
    #!${pkgs.stdenv.shell}
    ${play}/bin/play "$(wl-paste)"
  '';
  mpv-playlist = pkgs.writeScriptBin "mpv-playlist" ''
    #!${pkgs.bash}/bin/bash

    mapfile jq_command <<eof
    .data | .[] | (if has("current") then "> " else "  " end) + .filename
    eof

    echo '{ "command": ["get_property", "playlist"] }' \
        | ${pkgs.socat}/bin/socat - "${mpv-socket}" \
        | ${pkgs.jq}/bin/jq -r "''${jq_command[*]}"
  '';
in {
  options = {
    mpv.ipc-socket = lib.mkOption {
      default = "/run/user/${builtins.toString nixos.users.users.vkleen.uid}/mpv";
    };
  };
  config = {
    home.packages = with pkgs; [
      mpv
      start-mpv play play-clip mpv-playlist
    ];
    xdg.configFile."mpv/mpv.conf".text = ''
      gpu-context=waylandvk
      vo=gpu
      hwdec=vaapi
      hwdec-codecs=all
      ytdl-format=bestvideo[height<=?720][vcodec*=h264][fps=60]+bestaudio[acodec=opus]/bestvideo[height<=?720][fps=60]+bestaudio/best[height<=?720]
      ytdl-raw-options=sub-format=en,write-srt=
    '';
    xdg.configFile."mpv/scripts".source = ./mpv/scripts;
    xdg.configFile."mpv/script-opts".source = ./mpv/script-opts;
  };
}
