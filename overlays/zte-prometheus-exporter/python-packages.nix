# Generated by pip2nix 0.8.0.dev1
# See https://github.com/nix-community/pip2nix

{ pkgs, fetchurl, fetchgit, fetchhg }:

self: super: {
  "pytimeparse" = super.buildPythonPackage rec {
    pname = "pytimeparse";
    version = "1.1.8";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/1b/b4/afd75551a3b910abd1d922dbd45e49e5deeb4d47dc50209ce489ba9844dd/pytimeparse-1.1.8-py2.py3-none-any.whl";
      sha256 = "1g9nc03jya5scx1xlsbypkk4xhrsdj948m1jlr3md7xxr1nbxdq4";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
}
