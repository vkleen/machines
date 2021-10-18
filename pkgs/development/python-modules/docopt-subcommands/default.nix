{ lib, buildPythonPackage, fetchPypi, docopt }:
buildPythonPackage rec {
  pname = "docopt_subcommands";
  version = "4.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-5RHDP5ZHTXVDM2FwCUQ7FkHCTnYU0FH4wNV0ZnDSJDo=";
  };

  propagatedBuildInputs = [ docopt ];
}
