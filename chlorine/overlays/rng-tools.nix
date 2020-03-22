self: super: {
#  rng-tools = super.rng-tools.overrideAttrs (o: {
#    name = "rng-tools-git";
#    src = self.fetchFromGitHub {
#      owner = "nhorman";
#      repo = "rng-tools";
#      rev = "901468598270db9c9f19f63f9812a94f5a44a487";
#      sha256 = "0jkqxigxnrxdwcyc7iyxv1f69whkawcgsly8gmnizl171z80gvy7";
#    };
#  });
}
