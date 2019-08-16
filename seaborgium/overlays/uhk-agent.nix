self: super: let
  version = "1.2.12";

  image = self.stdenv.mkDerivation {
    name = "uhk-agent-image";
    src = self.fetchurl {
      url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
      sha256 = "1gr3q37ldixcqbwpxchhldlfjf7wcygxvnv6ff9nl7l8gxm732l6";
    };
    buildCommand = ''
      mkdir -p $out
      cp $src $out/appimage
      chmod ugo+rx $out/appimage
    '';
  };

in {
  uhk-agent = self.writeScriptBin "uhk-agent" ''
                ${self.appimage-run}/bin/appimage-run ${image}/appimage
              '';
}
