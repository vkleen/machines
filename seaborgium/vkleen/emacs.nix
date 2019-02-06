{pkgs, config, ...}:

let
  emacsPackages = pkgs.emacsPackagesNgFor (pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
  });
  emacsPackage = emacsPackages.emacsWithPackages (epkgs: [ ]);
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
