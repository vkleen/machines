final: prev: {
  neovim-unwrapped = final.neovim-flake.packages.${final.system}.neovim.overrideAttrs (o: {
    patches = [ (final.lib.head o.patches) ];
  });
}
