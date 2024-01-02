{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.helix pkgs.marksman ];
  home.sessionVariables.EDITOR = "${lib.getExe pkgs.helix}";
  xdg.configFile."helix/config.toml".source = (pkgs.formats.toml { }).generate "config.toml" {
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
    editor.lsp = {
      display-messages = true;
    };
    keys.normal = {
      q = "move_prev_word_start";
      Q = "move_prev_long_word_start";
      X = "extend_line_above";
    };
  };

  xdg.configFile."helix/languages.toml".source = (pkgs.formats.toml { }).generate "languages.toml" {
    language-server."pyright" = {
      command = "pyright-langserver";
      args = [ "--stdio" ];
    };
    language-server.nil.config = {
      formatting.command = [ "${lib.getExe pkgs.nixpkgs-fmt}" ];
    };
    language-server.ruff = {
      command = "ruff-lsp";
      config.settings.args = [ ];
    };
    language-server."rust-analyzer".config = {
      checkOnSave = {
        allFeatures = true;
        overrideCommand = [ "cargo" "clippy" "--workspace" "--message-format=json" "--all-targets" "--all-features" ];
      };
      cargo = {
        allFeatures = true;
      };
    };
    language = [
      {
        name = "nickel";
        auto-format = true;
      }
      {
        name = "nix";
        auto-format = true;
      }
      {
        name = "python";
        roots = [ "pyproject.toml" "requirements_lock.txt" ];
        scope = "source.python";
        injection-regex = "python";
        language-servers = [ "pyright" "ruff" ];
        auto-format = true;
        formatter = {
          command = "black";
          args = [ "--quiet" "--line-length=80" "-" ];
        };
      }
      {
        name = "rust";
        auto-format = true;
      }
    ];
  };
}
