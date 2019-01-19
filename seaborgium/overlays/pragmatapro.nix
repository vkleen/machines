let name = "pragmatapro-${version}";
    version = "0.827";
in self: super: {
  pragmatapro = self.runCommand name rec {
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "064c66g3rcw4crhdwnx8jhddb1mjm1qg9gf62lapkj7ni44pyq26";

    src = self.requireFile rec {
      name = "PragmataPro${version}.zip";
      url = "file://path/to/${name}";
      sha256 = "0aryjsmcrqaybx8yy6bnx0hgvblmpsh8z8ppmh35v4hkq0aq19gx";
    };

    buildInputs = [ self.unzip ];
  } ''
    unzip $src
    install_path=$out/share/fonts/truetype/pragmatapro
    mkdir -p $install_path
    find -name "PragmataPro*.ttf" -and -not -name "*liga*" -exec cp {} $install_path \;
  '';
}
