{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    kitty
  ];
  xdg.configFile."kitty/kitty.conf".text = ''
    kitty_mod ctrl+shift

    font_family PragmataPro Mono Liga Regular
    bold_font PragmataPro Mono Liga Bold
    italic_font PragmataPro Mono Liga Italic
    bold_italic_font PragmataPro Mono Liga Bold Italic

    font_size 12.0
    force_ltr no

    adjust_line_height 0
    adjust_column_width 0

    disable_ligatures cursor
    font_features PragmataProMonoLiga-Regular +calt

    box_drawing_scale 0.001, 1, 1.5, 2

    cursor_shape block
    cursor_blink_interval 0

    scrollback_lines 0

    url_color #2aa198
    url_style curly

    open_url_modifiers kitty_mod

    copy_on_select yes

    strip_trailing_spaces always

    enable_audio_bell no
    visual_bell_duration 0

    foreground #adbcbc
    background #103c48

    background_opacity 1.0

    color0 #174956
    color8 #325b66

    color1 #fa5750
    color9 #ff665c

    color2  #75b938
    color10 #84c747

    color3  #dbb32d
    color11 #ebc13d

    color4  #4695f7
    color12 #58a3ff

    color5  #f275be
    color13 #ff84cd

    color6  #41c7b9
    color14 #53d6c7

    color7  #72898f
    color15 #cad8d9

    clipboard_control write-clipboard write-primary

    linux_display_server wayland

    clear_all_shortcuts yes

    map kitty_mod+e kitten hints --program wl-copy
    map kitty_mod+u kitten unicode_input
  '';
}
