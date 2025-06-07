{ ... }:
{
  programs.foot = {
    enable = true;
    server.enable = false;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Pragmasevka:size=12";
      };
      scrollback = {
        lines = 0;
      };
    };
  };
}
