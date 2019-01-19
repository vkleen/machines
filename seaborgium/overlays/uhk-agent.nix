self: super: let
  version = "1.2.9";

  image = self.stdenv.mkDerivation {
    name = "uhk-agent-image";
    src = self.fetchurl {
      url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
      sha256 = "07afjs7yxh61mrjbcb463ik5p0jf8zzs5gv3lr3grvcga6kvvk0s";
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
