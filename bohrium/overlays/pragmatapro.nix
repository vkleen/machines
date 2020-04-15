let name = "pragmatapro-${version}";
    version = "0.828-2";
in self: super: {
  pragmatapro = self.runCommand name rec {
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "0zh21h1rq96q8l0k1135pvdwcik0fsjbcqmsq46fhv7f9j936zlx";

    src = self.requireFile rec {
      name = "PragmataPro${version}.zip";
      url = "file://path/to/${name}";
      sha256 = "19q6d0dxgd9k2mhr31944wpprks1qbqs1h5f400dyl5qzis2dji3";
    };

    buildInputs = [ self.unzip ];
  } ''
    unzip $src
    install_path=$out/share/fonts/truetype/pragmatapro
    mkdir -p $install_path
    find -name "PragmataPro*.ttf" -and -not -name "*liga*" -exec cp {} $install_path \;
  '';
}
