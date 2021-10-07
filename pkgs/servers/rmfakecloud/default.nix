{ lib, fetchFromGitHub, mkYarnPackage, buildGoModule, rmfakecloud-src }:
let
  src = rmfakecloud-src;

  uiFiles = mkYarnPackage {
    name = "rmfakecloud-ui";
    src = "${src}/ui";
    packageJSON = "${src}/ui/package.json";
    yarnLock = "${src}/ui/yarn.lock";
    yarnNix = ./yarn.nix;

    configurePhase = ''
      cp -r $node_modules node_modules
      chmod -R u+w node_modules
    '';
    buildPhase = ''
      yarn --offline --frozen-lockfile build
    '';
    installPhase = ''
      mv build $out
    '';
    distPhase = "true";
  };
in buildGoModule rec {
  pname = "rmfakecloud";
  version = "0.0.5";
  inherit src;
  vendorSha256 = "sha256-cNRXoarWrMgvseBEAjyBrBTFts0hJpZzPnTDXKJOUJM=";

  overrideModAttrs = (_: { preBuild = "true"; });

  patches = [ ./tools.patch ];

  postPatch = ''
    ln -s ${uiFiles} ui/build
  '';

  preBuild = ''
    go generate ./...
  '';

  doCheck = false;
}
