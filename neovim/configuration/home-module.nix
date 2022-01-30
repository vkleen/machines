{ pkgs, config, lib, neovim, ...}:
let
  cfg = config.neovim-config;

  neovide-wrapped = pkgs.writeShellScriptBin "neovide" ''
    exec ${neovim.neovide}/bin/neovide --multigrid "$@"
  '';
in {
  options.neovim-config = {
    enable = lib.mkEnableOption "neovim-config";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";
    };
    home.packages = [
      neovide-wrapped
      pkgs.neovim-remote
    ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      withPython3 = true;

      extraPackages = with pkgs; [
        jq curl
        rnix-lsp
      ];

      plugins = with neovim.vimPlugins; [
        fzf-vim
        (nvim-treesitter.withPlugins (p: builtins.attrValues p))

        plenary-nvim
      ];
    };
  };
}
