{ config, ... }:
{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        file-browser = {
          enable = true;
          settings = {
            use_fd = true;
            hijack_netrw = true;
          };
        };
        fzf-native = {
          enable = true;
          settings.case_mode = "smart_case";
        };
        ui-select = {
          enable = true;
        };
        undo = {
          enable = true;
          settings.use_delta = true;
        };
      };
      keymaps = {
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Grep";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Files";
        };
        "<leader>b" = {
          action = "buffers";
          options.desc = "Buffers";
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>fb";
        action = config.nixvim.helpers.mkRaw /*lua*/"require('telescope').extensions.file_browser.file_browser";
        options.desc = "File browser";
      }
      {
        mode = "n";
        key = "<leader>u";
        action = config.nixvim.helpers.mkRaw /*lua*/"require('telescope').extensions.undo.undo";
        options.desc = "Undo";
      }
    ];
  };
}
