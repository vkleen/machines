{ lib, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "dpt-rp1-py";
  version = "local-2019-02-15";

  src = fetchFromGitHub {
    owner = "vkleen";
    repo = "dpt-rp1-py";
    rev = "fc4d0912a818665867a864d44089a027d71ec5b9";
    sha256 = "07381k4a3y67vmnakjldr8dah2m04inyfhf8ydv2l1gb57pzmsvn";
  };

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [
    httpsig
    requests
    pbkdf2
    urllib3
    setuptools
  ];

  meta = with lib; {
    homepage = "https://github.com/janten/dpt-rp1-py";
    description = "Python script to manage Sony DPT-RP1 without Digital Paper App";
    license = licenses.mit;
    maintainers = with maintainers; [ mt-caret ];
  };
}
