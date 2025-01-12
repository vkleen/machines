{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      scrolling = {
        history = 0;
      };
      selection = {
        save_to_clipboard = true;
      };
    };
  };
}
