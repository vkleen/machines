{ inputs, ... }:
let
  inherit (inputs.nixvim.lib.x86_64-linux) helpers;
in
{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        file_browser = {
          enable = true;
          useFd = true;
          hijackNetrw = true;
        };
        fzf-native = {
          enable = true;
          caseMode = "smart_case";
        };
        ui-select = {
          enable = true;
        };
        undo = {
          enable = true;
          useDelta = true;
        };
      };
      keymaps = {
        "<leader>fg" = {
          action = "live_grep";
          desc = "Grep";
        };
        "<leader>ff" = {
          action = "find_files";
          desc = "Files";
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>fb";
        action = helpers.mkRaw /*lua*/"require('telescope').extensions.file_browser.file_browser";
        options.desc = "File browser";
      }
      {
        mode = "n";
        key = "<leader>u";
        action = helpers.mkRaw /*lua*/"require('telescope').extensions.undo.undo";
        options.desc = "Undo";
      }
    ];
  };
}
