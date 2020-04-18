{pkgs, config, ...}:

let
  emacsPackages = pkgs.emacsPackagesNgFor (pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
  });
  emacsPackage = emacsPackages.emacsWithPackages (epkgs: [ epkgs.pdf-tools epkgs.forge epkgs.emacsql epkgs.emacsql-sqlite ]);
in {
  home.packages = [ emacsPackage ];

  xresources.properties = {
    "emacs.FontBackend" = "xft";
  };
}
