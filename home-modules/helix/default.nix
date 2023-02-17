{config, nixos, pkgs, lib, ...}:
{
  home.packages = [ pkgs.helix ];
  home.sessionVariables.EDITOR = "${pkgs.helix}/bin/hx";
  xdg.configFile."helix/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
    theme = "base16_default_dark";
    editor = {
      auto-pairs = true;
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

  xdg.configFile."helix/languages.toml".source = (pkgs.formats.toml {}).generate "languages.toml" {
    language = [
      {
        name = "nix";
        config = {
          nil.formatting.command = ["${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"];
        };
      }
      {
        name = "python";
        roots = ["pyproject.toml"];
        language-server = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };
        config = {};
      }
    ];
  };
}
