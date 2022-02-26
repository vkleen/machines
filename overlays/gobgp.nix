final: prev: {
  gobgp = final.buildGoModule {
    pname = "gobgpd";
    version = "flake";
    src = final.gobgp-src;
    vendorSha256 = "sha256-RSsvFD3RvYKxdwPDGG3YHVUzKLgwReZkoVabH5KWXMA=";

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
    vendorSha256 = "sha256-RSsvFD3RvYKxdwPDGG3YHVUzKLgwReZkoVabH5KWXMA=";

    postConfigure = ''
      export CGO_ENABLED=0
    '';

    ldflags = [
      "-s" "-w" "-extldflags '-static'"
    ];

    subPackages = [ "cmd/gobgpd" ];
  };
}
