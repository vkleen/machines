final: prev: {
  rmapi = final.buildGoModule {
    pname = "rmapi";
    version = "0.0.17";

    src = final.rmapi-src;

    vendorSha256 = "sha256-Id2RaiSxthyR6egDQz2zulbSZ4STRTaA3yQIr6Mx9kg=";

    doCheck = false;
  };
}
