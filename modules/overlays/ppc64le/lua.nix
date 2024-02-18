{ ... }:
final: prev: {
  luajit = final.luajit_openresty;
  luajit_2_1 = final.luajit_openresty;
  luajit_openresty = (prev.luajit_openresty.override {
    self = final.luajit_openresty;
  }).overrideAttrs (o: rec {
    version = "7a41f159308b8291496acd044c9f3e8b17a64cb8";

    src = final.fetchFromGitHub {
      owner = "openresty";
      repo = "luajit2";
      rev = "${version}";
      hash = "sha256-2veASE3tOEZpZ0qOxV7KYisC2twG3fJMRNywXmpL4X8=";
    };

    meta = o.meta // {
      badPlatforms = [ ];
    };
  });
}
