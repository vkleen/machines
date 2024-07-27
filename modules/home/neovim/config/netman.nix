{ lib, ... }:
{
  programs.nixvim = {
    plugins.netman = {
      enable = true;
      neoTreeIntegration = true;
    };
    keymaps = lib.mapAttrsToList
      (k: v: {
        mode = "n";
        key = k;
      } // v)
      {
        "<leader>fr" = {
          action = ":Neotree remote<CR>";
          options = {
            desc = "Neotree remote";
            silent = true;
          };
        };
      };
  };
}

