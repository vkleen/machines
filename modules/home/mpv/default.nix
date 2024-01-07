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

  mpv-autosave = pkgs.runCommand "mpv-autosave"
    {
      src = pkgs.fetchzip {
        url = "https://gist.github.com/CyberShadow/2f71a97fb85ed42146f6d9f522bc34ef/archive/744c3ee61d2f0a8e9bb4e308dec6897215ae4704.zip";
        hash = "sha256-yxA8wgzdS7SyKLoNTWN87ShsBfPKUflbOu4Y0jS2G3I=";
      };
      passthru.scriptName = "autosave.lua";
    } ''
    mkdir -p $out/share/mpv/scripts
    cp $src/autosave.lua $out/share/mpv/scripts
  '';

  mpv-reload = pkgs.runCommand "youtube-quality"
    {
      src = pkgs.fetchFromGitHub {
        owner = "4e6";
        repo = "mpv-reload";
        rev = "133d596f6d369f320b4595bbed1f4a157b7b9ee5";
        sha256 = "B+4TCmf1T7MuwtbL+hGZoN1ktI31hnO5yayMG1zW8Ng=";
      };
      passthru.scriptName = "reload.lua";
    } ''
    mkdir -p $out/share/mpv/scripts
    cp $src/reload.lua $out/share/mpv/scripts
  '';

  mpvPackage = pkgs.mpv.override {
    scripts = [
      mpv-reload
      mpv-autosave
      pkgs.mpvScripts.quality-menu
      pkgs.mpvScripts.mpris
    ];
  };
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
      mpvPackage
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
      "mpv/input.conf".text = ''
        Ctrl+f script-binding quality_menu/video_formats_toggle
        Alt+f script-binding quality_menu/audio_formats_toggle
      '';
      "mpv/script-opts/quality-menu.conf".text = ''
        # KEY BINDINGS

        # move the menu cursor up
        up_binding=UP WHEEL_UP
        # move the menu cursor down
        down_binding=DOWN WHEEL_DOWN
        # select menu entry
        select_binding=ENTER MBTN_LEFT
        # close menu
        close_menu_binding=ESC MBTN_RIGHT

        # youtube-dl version(could be youtube-dl or yt-dlp, or something else)
        ytdl_ver=yt-dlp

        # formatting / cursors
        selected_and_active=▶  - 
        selected_and_inactive=●  - 
        unselected_and_active=▷ - 
        unselected_and_inactive=○ - 

        # font size scales by window, if false requires larger font and padding sizes
        scale_playlist_by_window=yes

        # playlist ass style overrides inside curly brackets, \keyvalue is one field, extra \ for escape in lua
        # example {\\fnUbuntu\\fs10\\b0\\bord1} equals: font=Ubuntu, size=10, bold=no, border=1
        # read https://aegi.vmoe.info/docs/3.0/ASS_Tags/ for reference of tags
        # undeclared tags will use default osd settings
        # these styles will be used for the whole playlist. More specific styling will need to be hacked in
        #
        # (a monospaced font is recommended but not required)
        style_ass_tags={\\fnmonospace\\fs25\\bord1}

        # Shift drawing coordinates. Required for mpv.net compatiblity
        shift_x=0
        shift_y=0

        # paddings for top left corner
        text_padding_x=5
        text_padding_y=10

        # Screen dim when menu is open
        curtain_opacity=0.7

        # how many seconds until the quality menu times out
        # setting this to 0 deactivates the timeout
        menu_timeout=6

        # use youtube-dl to fetch a list of available formats (overrides quality_strings)
        fetch_formats=yes

        # list of ytdl-format strings to choose from
        quality_strings_video=[ {"4320p" : "bestvideo[height<=?4320p]"}, {"2160p" : "bestvideo[height<=?2160]"}, {"1440p" : "bestvideo[height<=?1440]"}, {"1080p" : "bestvideo[height<=?1080]"}, {"720p" : "bestvideo[height<=?720]"}, {"480p" : "bestvideo[height<=?480]"}, {"360p" : "bestvideo[height<=?360]"}, {"240p" : "bestvideo[height<=?240]"}, {"144p" : "bestvideo[height<=?144]"} ]
        quality_strings_audio=[ {"default" : "bestaudio"} ]

        # automatically fetch available formats when opening an url
        fetch_on_start=yes

        # show the video format menu after opening an url
        start_with_menu=no

        # include unknown formats in the list
        # Unfortunately choosing which formats are video or audio is not always perfect.
        # Set to true to make sure you don't miss any formats, but then the list
        # might also include formats that aren't actually video or audio.
        # Formats that are known to not be video or audio are still filtered out.
        include_unknown=no

        # hide columns that are identical for all formats
        hide_identical_columns=yes

        # which columns are shown in which order
        # comma separated list, prefix column with "-" to align left
        #
        # for the uosc integration it is possible to split the text up into a title and a hint
        # this is done by separating two columns with a "|" instead of a comma
        # column order in the hint is reversed
        #
        # columns that might be useful are:
        # resolution, width, height, fps, dynamic_range, tbr, vbr, abr, asr,
        # filesize, filesize_approx, vcodec, acodec, ext, video_ext, audio_ext,
        # language, format, format_note, quality
        #
        # columns that are derived from the above, but with special treatment:
        # size, frame_rate, bitrate_total, bitrate_video, bitrate_audio,
        # codec_video, codec_audio, audio_sample_rate
        #
        # If those still aren't enough or you're just curious, run:
        # yt-dlp -j <url>
        # This outputs unformatted JSON.
        # Format it and look under "formats" to see what's available.
        #
        # Not all videos have all columns available.
        # Be careful, misspelled columns simply won't be displayed, there is no error.
        columns_video=-resolution,frame_rate,dynamic_range|language,bitrate_total,size,-codec_video,-codec_audio
        columns_audio=audio_sample_rate,bitrate_total|size,language,-codec_audio

        # columns used for sorting, see "columns_video" for available columns
        # comma separated list, prefix column with "-" to reverse sorting order
        # Leaving this empty keeps the order from yt-dlp/youtube-dl.
        # Be careful, misspelled columns won't result in an error,
        # but they might influence the result.
        sort_video=height,fps,tbr,size,format_id
        sort_audio=asr,tbr,size,format_id
      '';
    };
  };
}
