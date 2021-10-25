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

  mpv-autosave = pkgs.fetchzip {
    url = "https://gist.github.com/CyberShadow/2f71a97fb85ed42146f6d9f522bc34ef/archive/744c3ee61d2f0a8e9bb4e308dec6897215ae4704.zip";
    hash = "sha256-yxA8wgzdS7SyKLoNTWN87ShsBfPKUflbOu4Y0jS2G3I=";
  };

  mpv-youtube-quality = pkgs.runCommand "youtube-quality" {
      src = pkgs.fetchzip {
        url = "https://github.com/jgreco/mpv-youtube-quality/archive/1f8c31457459ffc28cd1c3f3c2235a53efad7148.zip";
        hash = "sha256-voNP8tCwCv8QnAZOPC9gqHRV/7jgCAE63VKBd/1s5ic=";
      };
    } ''
      mkdir -p $out
      cp $src/youtube-quality.lua $out/
    '';

  mpv-reload = pkgs.runCommand "youtube-quality" {
      src = pkgs.fetchzip {
        url = "https://github.com/4e6/mpv-reload/archive/2b8a719fe166d6d42b5f1dd64761f97997b54a86.zip";
        hash = "sha256-b8HLvBj8sOg+RPQlHUVq2VFoKA2TtGEe2G8j97ndzKc=";
      };
    } ''
      mkdir -p $out
      cp $src/reload.lua $out/
    '';
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
      vo=gpu
      hwdec=vaapi
      hwdec-codecs=all
      script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp
      ytdl-format=bestvideo[height<=?720][vcodec*=h264][fps=60]+bestaudio[acodec=opus]/bestvideo[height<=?720][fps=60]+bestaudio/best[height<=?720]
      ytdl-raw-options=sub-format=en,write-srt=
    '';
    xdg.configFile = {
      "mpv/scripts".source = pkgs.symlinkJoin {
        name = "mpv-scripts";
        paths = [
          mpv-autosave
          mpv-youtube-quality
          mpv-reload
        ];
      };
      "mpv/script-opts/youtube-quality.conf".text = ''
        # KEY BINDINGS

        # invoke or dismiss the quality menu
        toggle_menu_binding=ctrl+f
        # move the menu cursor up
        up_binding=UP
        # move the menu cursor down
        down_binding=DOWN
        # select menu entry
        select_binding=ENTER

        # formatting / cursors
        selected_and_active=▶ -
        selected_and_inactive=● -
        unselected_and_active=▷ -
        unselected_and_inactive=○ -

        # font size scales by window, if false requires larger font and padding sizes
        scale_playlist_by_window=no

        # playlist ass style overrides inside curly brackets, \keyvalue is one field, extra \ for escape in lua
        # example {\\fnUbuntu\\fs10\\b0\\bord1} equals: font=Ubuntu, size=10, bold=no, border=1
        # read http://docs.aegisub.org/3.2/ASS_Tags/ for reference of tags
        # undeclared tags will use default osd settings
        # these styles will be used for the whole playlist. More specific styling will need to be hacked in
        #
        # (a monospaced font is recommended but not required)
        style_ass_tags={\\fnmonospace}

        # paddings for top left corner
        text_padding_x=5
        text_padding_y=5

        # how many seconds until the quality menu times out
        menu_timeout=10

        #use youtube-dl to fetch a list of available formats (overrides quality_strings)
        fetch_formats=yes

        # list of ytdl-format strings to choose from
        quality_strings=[ {"4320p" : "bestvideo[height<=?4320p]+bestaudio/best"}, {"2160p" : "bestvideo[height<=?2160]+bestaudio/best"}, {"1440p" : "bestvideo[height<=?1440]+bestaudio/best"}, {"1080p" : "bestvideo[height<=?1080]+bestaudio/best"}, {"720p" : "bestvideo[height<=?720]+bestaudio/best"}, {"480p" : "bestvideo[height<=?480]+bestaudio/best"}, {"360p" : "bestvideo[height<=?360]+bestaudio/best"}, {"240p" : "bestvideo[height<=?240]+bestaudio/best"}, {"144p" : "bestvideo[height<=?144]+bestaudio/best"} ]
      '';
    };
  };
}
