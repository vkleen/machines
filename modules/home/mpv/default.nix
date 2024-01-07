{ pkgs, config, lib, ... }:
let
  mpv-socket = config.mpv.ipc-socket;
  socat = lib.getExe pkgs.socat;
  jq = lib.getExe pkgs.jq;

  mpv-playlist = pkgs.writeShellScriptBin "mpv-playlist" ''
    [[ -S "${mpv-socket}" ]] || exit 1

    mapfile jq_command <<eof
    .data | .[] | .filename + (if has("current") then " <" else "" end)
    eof

    echo '{ "command": ["get_property", "playlist"] }' \
        | ${socat} - "${mpv-socket}" \
        | ${jq} -r "''${jq_command[*]}"
  '';
  mpv-clear = pkgs.writeShellScriptBin "mpv-clear" ''
    [[ -S "${mpv-socket}" ]] || exit 1

    echo '{ "command": ["playlist-clear"] }' | ${socat} - "${mpv-socket}"
  '';

  mpv-pause-toggle = pkgs.writeShellScriptBin "mpv-pause-toggle" ''
    [[ -S "${mpv-socket}" ]] || exit 1

    STATE=$(echo '{ "command": ["get_property", "pause"] }' | ${socat} - "${mpv-socket}" | ${jq} -r '.data')
    case "$STATE" in
      false) echo '{ "command": ["set_property", "pause", true] }' | ${socat} - "${mpv-socket}" ;;
      true) echo '{ "command": ["set_property", "pause", false] }' | ${socat} - "${mpv-socket}" ;;
      *) exit 1;;
    esac
  '';

  mpv-pause = pkgs.writeShellScriptBin "mpv-pause" ''
    [[ -S "${mpv-socket}" ]] || exit 1

    echo '{ "command": ["set_property", "pause", true] }' | ${socat} - "${mpv-socket}"
  '';

  mpv-next = pkgs.writeShellScriptBin "mpv-next" ''
    [[ -S "${mpv-socket}" ]] || exit 1
    echo '{ "command": ["playlist-next", "force"] }' | ${socat} - "${mpv-socket}"
  '';
  mpv-prev = pkgs.writeShellScriptBin "mpv-prev" ''
    [[ -S "${mpv-socket}" ]] || exit 1
    echo '{ "command": ["playlist-prev"] }' | ${socat} - "${mpv-socket}"
  '';

  mpv-autosave = pkgs.fetchzip {
    url = "https://gist.github.com/CyberShadow/2f71a97fb85ed42146f6d9f522bc34ef/archive/744c3ee61d2f0a8e9bb4e308dec6897215ae4704.zip";
    hash = "sha256-yxA8wgzdS7SyKLoNTWN87ShsBfPKUflbOu4Y0jS2G3I=";
  };

  mpv-youtube-quality = pkgs.runCommand "youtube-quality"
    {
      src = pkgs.fetchFromGitHub {
        owner = "jgreco";
        repo = "mpv-youtube-quality";
        rev = "1f8c31457459ffc28cd1c3f3c2235a53efad7148";
        sha256 = "voNP8tCwCv8QnAZOPC9gqHRV/7jgCAE63VKBd/1s5ic=";
      };
    } ''
    mkdir -p $out
    cp $src/youtube-quality.lua $out/
  '';

  mpv-reload = pkgs.runCommand "youtube-quality"
    {
      src = pkgs.fetchFromGitHub {
        owner = "4e6";
        repo = "mpv-reload";
        rev = "133d596f6d369f320b4595bbed1f4a157b7b9ee5";
        sha256 = "B+4TCmf1T7MuwtbL+hGZoN1ktI31hnO5yayMG1zW8Ng=";
      };
    } ''
    mkdir -p $out
    cp $src/reload.lua $out/
  '';
in
{
  options = {
    mpv.ipc-socket = lib.mkOption {
      type = lib.types.str;
    };
    mpv.scripts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        mpv-playlist
        mpv-clear
        mpv-pause-toggle
        mpv-pause
        mpv-next
        mpv-prev
      ];
    };
  };
  config = {
    home.packages = [
      pkgs.mpv
    ] ++ config.mpv.scripts;

    xdg.configFile."mpv/mpv.conf".text = ''
      gpu-context=wayland
      gpu-api=opengl
      vo=gpu
      hwdec=vaapi
      hwdec-codecs=all
      script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp
      ytdl-format=bestvideo[fps=60]+bestaudio/bestvideo+bestaudio
      ytdl-raw-options=sub-format=en,write-srt=
      sub-ass-force-style=FontName=PragmataPro
      slang=en-US
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
