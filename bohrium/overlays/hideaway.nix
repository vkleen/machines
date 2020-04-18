self: super:
let
  hideaway =
    { stdenv, fetchurl, cmake }:

    let
      version = "0.1.0";
      pname = "interception-tools-hideaway";
    in stdenv.mkDerivation {
      name = "${pname}-${version}";

      src = fetchurl {
        url = "https://gitlab.com/interception/linux/plugins/hideaway/repository/v${version}/archive.tar.gz";
        sha256 = "0x6pc8r2dh58zsd5lx50w30g6y8dr62z96ixdfbc6k3rrldb9pac";
      };

      buildInputs = [ cmake ];

      meta = with stdenv.lib; {
        homepage = "https://gitlab.com/interception/linux/plugins/hideaway";
        description = "A plugin for Interception Tools to move the mouse pointer out of sight after a couple of seconds";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    };
in {
  interception-tools-plugins = super.interception-tools-plugins // {
    hideaway = self.callPackage hideaway {};
  };
}
