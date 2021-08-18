{ runCommand, requireFile, unzip }:
let name = "pragmatapro-${version}";
    version = "0.829";
in
runCommand name rec {
  # outputHashMode = "recursive";
  # outputHashAlgo = "sha256";
  # outputHash = "0zh21h1rq96q8l0k1135pvdwcik0fsjbcqmsq46fhv7f9j936zlx";

  src = requireFile rec {
    name = "PragmataPro${version}.zip";
    url = "file://path/to/${name}";
    sha256 = "sha256-Qbt7m6JRau5FgYwuh89davGwELHUSIbu0d/RvdoLF/Q=";
    # sha256 = "19q6d0dxgd9k2mhr31944wpprks1qbqs1h5f400dyl5qzis2dji3";
  };

  buildInputs = [ unzip ];
} ''
  unzip $src
  install_path=$out/share/fonts/truetype/pragmatapro
  mkdir -p $install_path
  find -name "PragmataPro*.ttf" -exec cp {} $install_path \;
''
