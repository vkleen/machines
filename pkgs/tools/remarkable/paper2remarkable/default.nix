{ lib,
  buildPythonPackage,
  fetchPypi,
  chardet,
  cryptography,
  pycryptodome,
  sortedcontainers,
  pillow,
  Wand,
  cssselect,
  lxml,
  timeout-decorator,
  beautifulsoup4,
  html2text,
  markdown,
  pikepdf,
  pyyaml,
  regex,
  requests,
  titlecase,
  unidecode,
  weasyprint
}:
let
  pdfminer-six = buildPythonPackage rec {
    pname = "pdfminer.six";
    version = "20200517";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-QpoJnSynbO3/eWUuF8/DfXdRom1Q8wrw+nkaafaKPdw=";
    };
    propagatedBuildInputs = [
      chardet cryptography pycryptodome sortedcontainers
    ];
  };

  pdfplumber = buildPythonPackage rec {
    pname = "pdfplumber";
    version = "0.5.28";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-FJjnHfB/PWhHiLIqanZFJt1z1rnXNlwSOf726moTdcY=";
    };
    propagatedBuildInputs = [
      pillow Wand pdfminer-six
    ];
    doCheck = false;
  };

  readability-lxml = buildPythonPackage rec {
    pname = "readability-lxml";
    version = "0.8.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-5R/qVrWQmq+IbTB9SOeeCWKTJVr6Vnt9CLypTSWxpOE=";
    };
    propagatedBuildInputs = [
      chardet cssselect lxml timeout-decorator
    ];
    doCheck = false;
  };
in buildPythonPackage rec {
  pname = "paper2remarkable";
  version = "0.9.9";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-UIdVPE/s7pE7/wya+AK7VyCX8R4O9vIAmE5wX2Kw1eU=";
  };
  patches = [ ./titlecase.patch ./springer.patch ];
  propagatedBuildInputs = [
    beautifulsoup4 html2text markdown pdfplumber pikepdf pycryptodome pyyaml
    readability-lxml regex requests titlecase unidecode weasyprint
  ];
  doCheck = false;
}
