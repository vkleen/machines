final: prev: {
  tuimoji = final.python3Packages.buildPythonApplication rec {
    pname = "tuimoji";
    version = "master";
    src = final.tuimoji-src;
    propagatedBuildInputs = with final.python3Packages; [ urwid setuptools ];
  };
}
