final: prev: {
  gobgp = final.buildGoModule {
    pname = "gobgpd";
    version = "flake";
    src = final.gobgp-src;
    vendorSha256 = "sha256-hw2cyKJaLBmPRdF4D+GVcVCkTpIK0HZasbMyYfLef1w=";

    postConfigure = ''
      export CGO_ENABLED=0
    '';

    ldflags = [
      "-s" "-w" "-extldflags '-static'"
    ];

    subPackages = [ "cmd/gobgp" ];
  };

  gobgpd = final.buildGoModule {
    pname = "gobgpd";
    version = "flake";
    src = final.gobgp-src;
    vendorSha256 = "sha256-hw2cyKJaLBmPRdF4D+GVcVCkTpIK0HZasbMyYfLef1w=";

    postConfigure = ''
      export CGO_ENABLED=0
    '';

    ldflags = [
      "-s" "-w" "-extldflags '-static'"
    ];

    subPackages = [ "cmd/gobgpd" ];
  };
}
