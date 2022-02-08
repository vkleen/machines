{ pkgs, config, lib, neovim, ...}:
let
  cfg = config.neovim-config;

  neovide-wrapped = pkgs.writeShellScriptBin "neovide" ''
    exec ${pkgs.neovide}/bin/neovide --multigrid "$@"
  '';

  finalPackage = pkgs.wrapNeovimUnstable neovim.neovim-unwrapped
    (neovimConfig  // {
      wrapperArgs = neovimConfig.wrapperArgs ++ [ "--suffix" "PATH" ":" "${lib.makeBinPath cfg.extraPackages}" ];
    });

  moduleConfigure = {
    packages.neovim-config = {
      start = [configurationPlugin];
      opt = [];
    };
    beforePlugins = "";
  };

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    configure = moduleConfigure;
    customRC = ''
      lua require"neovim-config".setup{}
    '';
  };

  configurationPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "neovim-config";
    src = ./.;
    dependencies = plugins;
  };
  plugins = with neovim.vimPlugins; [
    aerial-nvim
    cmp-buffer
    cmp-cmdline
    cmp_luasnip
    cmp-nvim-lsp
    cmp-nvim-lua
    cmp-path
    crates-nvim
    direnv-vim
    friendly-snippets
    gitsigns-nvim
    indent-blankline
    lsp-colors-nvim
    lspkind-nvim
    lspsaga-nvim
    lsp_signature
    lualine
    luasnip
    null-ls-nvim
    numb-nvim
    nvim-cmp
    nvim-colorizer
    nvim-dap
    nvim-dap-ui
    nvim-hlslens
    nvim-lspconfig
    nvim-notify
    nvim-tree
    nvim-treesitter-context
    (nvim-treesitter.withPlugins (p: builtins.attrValues p))
    nvim-ts-rainbow
    nvim-web-devicons
    plenary-nvim
    popup-nvim
    rust-tools
    telescope-dap-nvim
    telescope-fzf-nvim
    telescope-lsp-handlers
    telescope-nvim
    telescope-zoxide
    trouble-nvim
    which-key-nvim
  ];
in {
  options.neovim-config = {
    enable = lib.mkEnableOption "neovim-config";
    finalPackage = lib.mkOption {
      type = lib.types.package;
      visible = false;
      description = "Final customised neovim package";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        curl
        jq
        rnix-lsp
        stylua
      ];
      description = "Extra packages in PATH for neovim";
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "${config.neovim-config.finalPackage}/bin/nvim";
    };
    home.packages = [
      neovide-wrapped
      pkgs.neovim-remote
      cfg.finalPackage
    ];

    neovim-config.finalPackage = finalPackage;

    programs.zsh.shellAliases = { vimdiff = "${cfg.finalPackage}/bin/nvim -d"; };
  };
}
