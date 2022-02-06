{ buildRubyGem, ruby, power-assert-src }:
buildRubyGem {
  inherit ruby;

  pname = "power-assert";
  gemName = "power_assert";
  version = "flake";
  src = power-assert-src;
  patches = [ ./degitify.patch ];
}
