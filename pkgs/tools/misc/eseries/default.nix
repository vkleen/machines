{ lib, eseries-src, fetchFromGitHub, buildPythonPackage,
  docopt-subcommands, future, coverage, hypothesis, pytest, pytest-cov, coveralls,
  pytestCheckHook
}:
buildPythonPackage rec {
  pname = "eseries";
  version = "master";

  src = eseries-src;

  propagatedBuildInputs = [ docopt-subcommands future ];

  checkInputs = [ coverage hypothesis pytest pytest-cov coveralls pytestCheckHook ];
}
