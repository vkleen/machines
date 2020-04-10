{ buildGoPackage, arduino-cli }:
buildGoPackage rec {
  name = "arduino-cli-${version}";
  version = arduino-cli.branch;
  src = arduino-cli;
  goDeps = ./deps.nix;
  goPackagePath = "github.com/arduino/arduino-cli";
}
