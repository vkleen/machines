self: super: {
  linode-cli = self.python2.pkgs.buildPythonPackage rec {
    pname = "linode-cli";
    version = "2.0.18";
    src = self.fetchFromGitHub {
      owner = "linode";
      repo = "linode-cli";
      rev = "${version}";
      sha256 = "193y7279lqcsxi4y162f6nm38d48avdn78rjj1kmxxfb3m2zds6d";
    };
    spec = self.fetchurl {
      url = "https://developers.linode.com/api/v4/openapi.yaml";
      sha256 = "1wchplsv985ix6nz3b5r6f185mb750qhd412jh9yzy5vf6mdhlxj";
    };
    propagatedBuildInputs = with self.python2.pkgs; [
      terminaltables
      colorclass
      requests
      pyyaml
      enum34
    ];
    patchPhase = ''
      sed -i 's/version=get_version(),$/version="${version}",/' ./setup.py
    '';
    preBuild = ''
      python -m linodecli bake ${spec} --skip-config
      cp data-2 linodecli/
    '';
  };
}
