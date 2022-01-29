{ addRtp, pkgs, ...}:
final: prev: {
  gitsigns-nvim = prev.gitsigns-nvim.overrideAttrs (old: {
    dependencies = with final; [ plenary-nvim ];
  });

  # plenary-nvim = super.toVimPlugin(luaPackages.plenary-nvim);

  plenary-nvim = prev.plenary-nvim.overrideAttrs (old: {
    postInstall = ''
      chmod -R u+rw $out
      sed -Ei $out/lua/plenary/curl.lua \
          -e 's@(command\s*=\s*")curl(")@\1${pkgs.curl}/bin/curl\2@'
    '';
  });


  nvim-treesitter = prev.nvim-treesitter.overrideAttrs (old: {
    passthru.withPlugins =
      grammarFn: final.nvim-treesitter.overrideAttrs (_: {
        postPatch =
          let
            grammars = pkgs.tree-sitter.withPlugins grammarFn;
          in ''
            rm -r parser
            ln -s ${grammars} parser
          '';
      });
  });

  telescope-nvim = prev.telescope-nvim.overrideAttrs (old: {
    dependencies = with final; [ plenary-nvim popup-nvim ];
  });

  fzf-vim = prev.fzf-vim.overrideAttrs (old: {
    dependencies = with final; [ fzfWrapper ];
  });

  fzfWrapper = addRtp "." (pkgs.stdenv.mkDerivation {
    name = "vimplugin-fzfWrapper";
    pname = "fzf";
    unpackPhase = ":";
    buildPhase = ":";
    configurePhase = ":";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp -r "${pkgs.fzf}/share/vim-plugins/fzf/plugin/"* "$out"
      ln -s ${pkgs.fzf}/bin/fzf $out/bin/fzf
      runHook postInstall
    '';
  });


  direnv-vim = prev.direnv-vim.overrideAttrs (oa: {
    preFixup = oa.preFixup or "" + ''
      substituteInPlace $out/autoload/direnv.vim \
        --replace "let s:direnv_cmd = get(g:, 'direnv_cmd', 'direnv')" \
          "let s:direnv_cmd = get(g:, 'direnv_cmd', '${pkgs.lib.getBin pkgs.direnv}/bin/direnv')"
    '';
  });
}
