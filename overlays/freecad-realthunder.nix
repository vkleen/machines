final: prev: {
  freecad-realthunder = prev.freecad.overrideAttrs (o: {
    version = "realthunder-20200928";
    src = final.fetchFromGitHub {
      owner = "realthunder";
      repo = "FreeCAD";
      rev = "2024a17e638a91865f98c46886be2884dfa23605";
      hash = "sha256-Kx2BpiLrYw7pDDWO7XSza0dearuF68W3YkcgXfgrGy4=";
    };
    buildInputs = o.buildInputs ++ [ final.libspnav ];
  });
}
