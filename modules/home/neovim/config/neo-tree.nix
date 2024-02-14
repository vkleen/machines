{ lib, ... }:
{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      closeIfLastWindow = true;
    };
    keymaps = lib.mapAttrsToList
      (k: v: {
        mode = "n";
        key = k;
      } // v)
      {
        "<leader>ft" = {
          action = ":Neotree<CR>";
          options = {
            desc = "Neotree";
            silent = true;
          };
        };
      };
  };
}

