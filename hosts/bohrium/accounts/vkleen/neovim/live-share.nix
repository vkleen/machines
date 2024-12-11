{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      instant-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "live-share";
        src = pkgs.fetchFromGitHub {
          owner = "azratul";
          repo = "live-share.nvim";
          rev = "bf5e8e087c368aae0325a09d1ea43f2a08f5e9aa";
          hash = "sha256-fUYFdeP+T+KwGpvm0eh5GcAS35ZU5f0N9A/JsqBgHGA=";
        };
      })
    ];
    extraConfigLua = /*lua*/ ''
      vim.g.instant_username = vim.env.USER
      require("live-share").setup({
          port_internal = 9876, -- The local port to be used for the live share connection
          max_attempts = 20, -- Maximum number of attempts to read the URL from service(serveo.net or localhost.run), every 250 ms
          service_url = "/tmp/live-share-nvim-service.url", -- Path to the file where the URL from serveo.net will be stored
          service = "nokey@localhost.run", -- Service to use, options are serveo.net or localhost.run
        })
    '';
  };
}
