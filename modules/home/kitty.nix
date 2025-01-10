{ ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      mode = "no-cursor";
      enableFishIntegration = true;
    };
    settings = {
      enable_audio_bell = false;
      update_check_interval = 0;
      scrollback_lines = 0;
      cursor_trail = 1000;
      cursor_blink_interval = 0;
      copy_on_select = "clipboard";
    };
  };
}
