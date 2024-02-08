{ pkgs, inputs, ... }:
let
  inherit (inputs.nixvim.lib.x86_64-linux) helpers;
in
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [ nvim-fzf nvim-fzf-commands ];
    extraConfigLua = /*lua*/ ''
      vim.api.nvim_create_user_command(
          'Rg',
          function(opts)
              require('fzf-commands').rg(table.concat(opts.fargs, ' '))
          end,
          { nargs = '+' })
    '';
    keymaps = [
      {
        mode = "n";
        key = "<leader>f";
        action = helpers.mkRaw /*lua*/''
          function()
            require('fzf-commands').files()
          end
        '';
        options.desc = "Fzf file picker";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = helpers.mkRaw /*lua*/''
          function()
            require('fzf-commands').bufferpicker2()
          end
        '';
        options.desc = "Fzf buffer picker";
      }
      {
        mode = "n";
        key = "<leader>g";
        action = ":<C-u>Rg<space>";
        options.desc = "Fzf+Rg";
      }
    ];
  };
}
