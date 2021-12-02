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

  vendorSha256 = "sha256-hYioSWYJVJsF6PW3a2v6Nio0Kjtixi9h6iFET9EjAL8=";

  patches = [ ./assets.patch ];

  subPackages = [ "cmd/rmfakecloud" ];

  postPatch = ''
    cp -a ${uiFiles} ui/build
  '';

  doCheck = false;
}
