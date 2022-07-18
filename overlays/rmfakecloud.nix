final: prev: {
  rmfakecloud = final. buildGoModule rec {
    pname = "rmfakecloud";
    version = "flake";
  
    src = final.rmfakecloud-src;
  
    vendorSha256 = "sha256-NwDaPpjkQogXE37RGS3zEALlp3NuXP9RW//vbwM6y0A=";
  
    postPatch = ''
      # skip including the JS SPA, which is difficult to build
      sed -i '/go:/d' ui/assets.go
    '';
  
    ldflags = [
      "-s" "-w" "-X main.version=v${version}"
    ];
  
    meta = with final.lib; {
      description = "Host your own cloud for the Remarkable";
      homepage = "https://ddvk.github.io/rmfakecloud/";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [ pacien martinetd ];
    };
  };
}
