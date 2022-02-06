{ buildPythonPackage, dacite-src }:
buildPythonPackage {
  pname = "dacite";
  version = "flake";

  src = dacite-src;

  doCheck = false;
}
