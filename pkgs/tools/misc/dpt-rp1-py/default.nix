{ lib, python3, python3Packages, fetchFromGitHub, writeScript }:
let
  aux-python = python3.withPackages (p: [ p.pyserial ]);
  dptrp1-usb = writeScript "dptrp1-usb" ''
    #!${aux-python}/bin/python3
    import serial
    import sys
    with serial.Serial(sys.argv[1]) as ser:
        ser.write(b'\x01\x00\x00\x01\x00\x00\x00\x01\x01\x04')
  '';
in python3Packages.buildPythonApplication rec {
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

  postInstall = ''
    cp ${dptrp1-usb} $out/bin/dptrp1-usb
  '';

  meta = with lib; {
    homepage = "https://github.com/janten/dpt-rp1-py";
    description = "Python script to manage Sony DPT-RP1 without Digital Paper App";
    license = licenses.mit;
    maintainers = with maintainers; [ mt-caret ];
  };
}
