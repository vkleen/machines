{ runCommand, lib, fetchFromGitHub, requireFile, unzip, python3 }:
let name = "pragmatapro-${version}";
    version = "0.829";
    python = python3.withPackages (p: [ p.fontforge ]);

    nerdfonts-src = fetchFromGitHub {
      owner = "ryanoasis";
      repo = "nerd-fonts";
      rev = "b9e5b3a9a4a8237fc266ca39c67ff9e35675ebaf";
      hash = "sha256-XRWuGZ63CaBOURpPB5zagdNVP+XY4JcoBOBpOjrVVLw=";
    };
in
runCommand name rec {
  src = requireFile rec {
    name = "PragmataPro${version}.zip";
    url = "file://path/to/${name}";
    sha256 = "sha256-Qbt7m6JRau5FgYwuh89davGwELHUSIbu0d/RvdoLF/Q=";
  };

  buildInputs = [ unzip ];
} ''
  unzip $src
  install_path=$out/share/fonts/truetype/pragmatapro
  mkdir -p $install_path
  find -name 'PragmataPro*.ttf' -print | while read -d $'\n' file; do
    cp "$file" "$install_path"
  done
  find -name 'PragmataPro_Mono_R*.ttf' -print | while read -d $'\n' file; do
    ${python}/bin/python ${nerdfonts-src}/font-patcher --progressbars --mono --complete --careful --glyphdir "${nerdfonts-src}/src/glyphs/" --outputdir "$install_path" "$file"
  done
''
