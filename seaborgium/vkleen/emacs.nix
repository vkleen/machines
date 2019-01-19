{pkgs, config, ...}:

let
  emacsPackages = pkgs.emacsPackagesNgFor (pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
  });
  emacsPackage = emacsPackages.emacsWithPackages (epkgs: [ epkgs.pdf-tools ]);
in {
  home.packages = [ emacsPackage ];

  home.sessionVariables = let
    editorScript = pkgs.writeScriptBin "emacseditor" ''
      #!${pkgs.runtimeShell}
      exec ${emacsPackage}/bin/emacsclient --alternate-editor ${emacsPackage}/bin/emacs "$@"
    '';
  in {
    EDITOR = "${editorScript}/bin/emacseditor";
  };

  xresources.properties = {
    "emacs.FontBackend" = "xft";
  };
}
