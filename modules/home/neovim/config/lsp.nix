{ lib, ... }:
{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gr" = "references";
            "gy" = "type_definition";
            "<leader>rh" = "hover";
            "<leader>rx" = "code_action";
            "<leader>rs" = "signature_help";
          };
          diagnostic = {
            "[d" = "goto_next";
            "]d" = "goto_prev";
          };
        };
      };
      fidget = {
        enable = false;
        progress = {
          pollRate = 0.5;
          ignoreDoneAlready = true;
        };
      };
      inc-rename = {
        enable = true;
      };
    };
    keymaps = lib.mapAttrsToList
      (k: v: {
        mode = "n";
        key = k;
      } // v)
      {
        "<leader>rn" = {
          action = ":IncRename ";
          options.desc = "Rename";
        };
      };
  };
}
