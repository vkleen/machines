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
    [[ -S "${mpv-socket}" ]] || exit 1

    mapfile jq_command <<eof
    .data | .[] | .filename + (if has("current") then " <" else "" end)
    eof

    echo '{ "command": ["get_property", "playlist"] }' \
        | ${pkgs.socat}/bin/socat - "${mpv-socket}" \
        | ${pkgs.jq}/bin/jq -r "''${jq_command[*]}"
  '';
  mpv-clear = pkgs.writeScriptBin "mpv-clear" ''
    #!${pkgs.bash}/bin/bash
    [[ -S "${mpv-socket}" ]] || exit 1

    echo '{ "command": ["playlist-clear"] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}"
  '';

  mpv-pause-toggle = pkgs.writeScriptBin "mpv-pause-toggle" ''
    #!${pkgs.stdenv.shell}
    [[ -S "${mpv-socket}" ]] || exit 1

    STATE=$(echo '{ "command": ["get_property", "pause"] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}" | ${pkgs.jq}/bin/jq -r '.data')
    case "$STATE" in
      false) echo '{ "command": ["set_property", "pause", true] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}" ;;
      true) echo '{ "command": ["set_property", "pause", false] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}" ;;
      *) exit 1;;
    esac
  '';

  mpv-pause = pkgs.writeScriptBin "mpv-pause" ''
    #!${pkgs.stdenv.shell}
    [[ -S "${mpv-socket}" ]] || exit 1

    echo '{ "command": ["set_property", "pause", true] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}"
  '';

  mpv-next = pkgs.writeScriptBin "mpv-next" ''
    #!${pkgs.stdenv.shell}
    [[ -S "${mpv-socket}" ]] || exit 1
    echo '{ "command": ["playlist-next", "force"] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}"
  '';
  mpv-prev = pkgs.writeScriptBin "mpv-prev" ''
    #!${pkgs.stdenv.shell}
    [[ -S "${mpv-socket}" ]] || exit 1
    echo '{ "command": ["playlist-prev"] }' | ${pkgs.socat}/bin/socat - "${mpv-socket}"
  '';

  mpv-scripts = pkgs.buildEnv {
    name = "mpv-scripts";
    paths = [
      start-mpv play play-clip mpv-playlist mpv-clear
      mpv-pause-toggle mpv-pause mpv-next mpv-prev
    ];
  };
in {
  options = {
    mpv.ipc-socket = lib.mkOption {
      default = "/run/user/${builtins.toString nixos.users.users.vkleen.uid}/mpv";
    };
    mpv.scripts = lib.mkOption {
      type = lib.types.package;
      default = mpv-scripts;
    };
  };
  config = {
    home.packages = with pkgs; [
      mpv
      mpv-scripts
    ];
    xdg.configFile."mpv/mpv.conf".text = ''
      gpu-context=wayland
      gpu-api=opengl
      profile=gpu-hq
      vo=gpu
      hwdec=vaapi
      hwdec-codecs=all
      ytdl-format=bestvideo[height<=?720][vcodec*=h264][fps=60]+bestaudio[acodec=opus]/bestvideo[height<=?720][fps=60]+bestaudio/best[height<=?720]
      ytdl-raw-options=sub-format=en,write-srt=
    '';
    xdg.configFile."mpv/scripts".source = ./scripts;
    xdg.configFile."mpv/script-opts".source = ./script-opts;
  };
}
