final: prev: {
  lego = final.buildGoModule rec {
    pname = "lego";
    version = "flake";
  
    src = final.lego-src;
  
    vendorSha256 = "sha256-Se6nfAx8WRJ8jDT/QO5eFjvkdZmMa5PTpVNOBOtEbn0=";
  
    doCheck = false;
  
    subPackages = [ "cmd/lego" ];
  
    ldflags = [
      "-X main.version=${version}"
    ];
  
    meta = with final.lib; {
      description = "Let's Encrypt client and ACME library written in Go";
      license = licenses.mit;
      homepage = "https://go-acme.github.io/lego/";
      maintainers = teams.acme.members;
    };
  
    passthru.tests.lego = final.nixosTests.acme;
  };
}
