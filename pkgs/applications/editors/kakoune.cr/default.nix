{ crystal, jq, fetchFromGitHub, lib }:

crystal.buildCrystalPackage {
  pname = "kakoune.cr";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "alexherbo2";
    repo = "kakoune.cr";
    leaveDotGit = true;
    rev = "a0aa242f0e77e139859569fde77e09557e02a0e0";
    sha256 = "sha256-yxsANcq1XZzesG6B07M2wyRyB2IIoqB23aU1CucT2mU=";
  };
  crystalBinaries.kcr.src = "src/cli.cr";

  patches = [
    # ./0001-adjust-runtime-path.patch
  ];

  shardsFile = ./shards.nix;
  postPatch = ''
    cp ${./shard.lock} ./shard.lock
  '';

  installPhase = ''
    install -d $out/bin $out/share

    install bin/kcr $out/bin
    cp -R share/kcr $out/share

    for x in $out/share/kcr/*/kcr-*; do
      ln -s $x $out/bin/
    done
  '';

  doCheck = false;

  propagatedBuildInputs = [ jq ];
}
