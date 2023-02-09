{config, nixos, pkgs, lib, ...}:
{
  home.packages = [ pkgs.helix ];
  xdg.configFile."helix/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
    theme = "nord";
    editor = {
      auto-pairs = false;
      line-number = "relative";
      mouse = false;
      true-color = true;
    };
    editor.cursor-shape = {
      insert = "bar";
    };
    editor.file-picker = {
      hidden = false;
    };
    editor.indent-guides = {
      render = true;
    };
    keys.normal = {
      q = "move_prev_word_start";
      Q = "move_prev_long_word_start";
      X = "extend_line_above";
    };
  };
}
