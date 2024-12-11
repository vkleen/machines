{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      scrolling = {
        history = 0;
      };
      font = {
        normal = { family = "PragmataPro Mono"; style = "Regular"; };
        size = 12;
      };
      selection = {
        save_to_clipboard = true;
      };
    };
  };
}
