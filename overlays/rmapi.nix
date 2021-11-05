final: prev: {
  rmapi = final.buildGoModule {
    pname = "rmapi";
    version = "0.0.17";

    src = final.rmapi-src;

    vendorSha256 = "sha256-gu+BU2tL/xZ7D6lZ1ueO/9IB9H3NNm4mloCZaGqZskU=";

    doCheck = false;
  };
}
