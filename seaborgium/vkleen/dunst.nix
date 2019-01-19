{config, nixos, pkgs, lib, ...}:

{
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
      size = "32x32";
    };
    settings = {
      global = {
        font = "PragmataPro 13";
        format = "<b>%s</b>\\n%b";
        geometry = "300x5-30+50";
        separator_color = "frame";
        icon_position = "off";
        separator_height = 2;
        padding = 6;
        horizontal_padding = 6;
        stack_duplicates = "yes";
        hide_duplicates_count = "yes";
        indicate_hidden = "yes";
        alignment = "center";
        word_wrap = "yes";
        frame_width = 3;
      };
      urgency_low = {
        frame_color = "#51afef";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 4;
      };
      urgency_normal = {
        frame_color = "#98be65";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 6;
      };
      urgency_critical = {
        frame_color = "#ff6c6b";
        foreground = "#bbc2cf";
        background = "#282c34";
        timeout = 8;
      };
      rime_ignore = {
        summary = "*Rime*";
        format = "";
      };
      signed_on_ignore = {
        appname = "Pidgin";
        summary = "*signed on*";
        format = "";
      };
      signed_off_ignore = {
        appname = "Pidgin";
        summary = "*signed off*";
        format = "";
      };
    };
  };
}
