{ stdenv, buildPythonPackage, feedparser, fetchurl }:
buildPythonPackage {
  pname = "weechat-weemustfeed";
  version = "0.3";
  src = fetchurl {
    url = "https://weechat.org/files/scripts/weemustfeed.py";
    hash = "sha256:0s6v9a2x1bkzxwjbadg7xchwrxzg1jgrgqgmcw8fidvarrdjzbj4";
  };

  passthru.scripts = [ "weemustfeed.py" ];
  propagatedBuildInputs = [
    feedparser
  ];

  dontBuild = true;
  dontUnpack = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share
    cp $src $out/share/weemustfeed.py
  '';
}
