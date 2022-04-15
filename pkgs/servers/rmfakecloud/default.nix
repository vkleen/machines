{ lib, stdenv, yarn2nix, fetchFromGitHub, mkYarnPackage, buildGoModule, rmfakecloud-src }:
let
  src = rmfakecloud-src;

  yarnNix = stdenv.mkDerivation {
    name = "yarn.nix";
    nativeBuildInputs = [yarn2nix];
    src = "${src}/ui";
    buildPhase = ''
      runHook preBuild
      yarn2nix --builtin-fetchgit > $out
      runHook postBuild
    '';
    installPhase = "true";
    distPhase = "true";

    outputHash = "sha256-ZgenH65Ixp3DjmKrmgYwkrZasQqgZ2lZtzw4CEjEUlE=";
  };

  uiFiles = mkYarnPackage {
    name = "rmfakecloud-ui";
    src = "${src}/ui";
    packageJSON = "${src}/ui/package.json";
    yarnLock = "${src}/ui/yarn.lock";
    inherit yarnNix;

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
  version = "flake";
  inherit src;

  vendorSha256 = "sha256-NwDaPpjkQogXE37RGS3zEALlp3NuXP9RW//vbwM6y0A=";

  patches = [ ./assets.patch ];

  subPackages = [ "cmd/rmfakecloud" ];

  postPatch = ''
    cp -a ${uiFiles} ui/build
  '';

  doCheck = false;

  passthru = {
    inherit yarnNix;
  };
}
