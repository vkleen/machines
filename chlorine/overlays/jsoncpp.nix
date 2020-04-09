self: super: {
  jsoncpp = super.jsoncpp.overrideAttrs (o: {
    cmakeFlags = (o.cmakeFlags or []) ++ [ "-DJSONCPP_WITH_TESTS=off" ];
  });
}
