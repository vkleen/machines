{ lib
, kikit-src
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, numpy
, shapely
, click
, markdown2
, commentjson
, prettytable
, wcwidth
, pypng
, ply
, kicad
, versioneer
, setuptools
, wxPython
}:
let
  pymeta3 = buildPythonPackage rec {
    pname = "PyMeta3";
    version = "0.5.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-GL2jJtmpu/WHv8DuC8loZJZNeLBnKIvPVdTZhoHQW8s=";
    };
    doCheck = false;
  };

  pybars3 = buildPythonPackage rec {
    pname = "pybars3";
    version = "0.9.7";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-ashH6QXlO5xbk2rxEskQR14nv3Z/efRSjBb5rx7A4lI=";
    };
    propagatedBuildInputs = [ pymeta3 ];
    doCheck = false;
  };

  prettytable_0_7_2 = buildPythonPackage rec {
    pname = "prettytable";
    version = "0.7.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-LVRg3J23SjK8yPn2feaLLE9NLwH6O9UYdkxpFW2crNk=";
    };
    propagatedBuildInputs = [ wcwidth ];
    doCheck = false;
  };

  pypng_0_0_19 = buildPythonPackage rec {
    pname = "pypng";
    version = "0.0.19";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "drj11";
      repo = "pypng";
      rev = "${pname}-${version}";
      sha256 = "sha256-XVsXgvLVFfxrRXDwdZO7oi7LPozN2XiYeXCK9NTx4Qs=";
    };
    doCheck = false;
    buildInputs = [ setuptools ];
  };

  euclid3 = buildPythonPackage rec {
    pname = "euclid3";
    version = "0.01";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-JbgnpXrb/Zo/qGJeQ6vD6Qf2HeYiND5+U4SC75tG/Qs=";
    };
    doCheck = false;
  };

  solidpython = buildPythonPackage rec {
    pname = "solidpython";
    version = "1.1.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-GgH5msqAL9oKjyBX29mnvy7XsB4iX69UmPk7M3vEEsg=";
    };
    propagatedBuildInputs = [ prettytable_0_7_2 pypng_0_0_19 ply euclid3 ];
    doCheck = false;
  };

  pcbnewTransition = buildPythonPackage rec {
    pname = "pcbnewTransition";
    version = "0.3.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-UVJ4+psNmsNB1penBxVLHcOP0F8+O6O4M7i7+IrGKQs=";
    };
    buildInputs = [ versioneer ];
    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "kikit";
  version = "master";

  src = kikit-src;

  buildInputs = [ versioneer ];
  propagatedBuildInputs = [ numpy shapely click markdown2 pybars3 solidpython commentjson kicad pcbnewTransition wxPython ];
}
