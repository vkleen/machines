{ lib, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "dpt-rp1-py";
  version = "local-2020-10-28";

  src = fetchFromGitHub {
    owner = "vkleen";
    repo = "dpt-rp1-py";
    rev = "fb9c49d614ad4ec9c9a04eab5d7299e151d586a6";
    hash = "sha256-0foVGUZZA2UFj8WfPfB+TiecT9aHHPad9j6/7XqWQ/8=";
  };

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [
    anytree
    fusepy
    httpsig
    pbkdf2
    pyyaml
    requests
    setuptools
    tqdm
    urllib3
    zeroconf
  ];

  meta = with lib; {
    homepage = "https://github.com/janten/dpt-rp1-py";
    description = "Python script to manage Sony DPT-RP1 without Digital Paper App";
    license = licenses.mit;
    maintainers = with maintainers; [ mt-caret ];
  };
}
