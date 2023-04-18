final: prev:
let
  name = "pragmatapro-${version}";
  version = "0.829";
in
{
  pragmatapro = final.runCommand name
    {
      src = final.requireFile rec {
        name = "PragmataPro${version}.zip";
        url = "file://path/to/${name}";
        sha256 = "sha256-Qbt7m6JRau5FgYwuh89davGwELHUSIbu0d/RvdoLF/Q=";
      };

      nativeBuildInputs = [ final.unzip final.nerd-font-patcher ];
    } ''
    unzip $src
    install_path=$out/share/fonts/truetype/pragmatapro
    mkdir -p $install_path
    find -name 'PragmataPro*.ttf' -print | while read -d $'\n' file; do
      cp "$file" "$install_path"
    done
    find -name 'PragmataProR*.ttf' -print | while read -d $'\n' file; do
      nerd-font-patcher --progressbars --complete --outputdir "$install_path" "$file"
    done
  '';
}
