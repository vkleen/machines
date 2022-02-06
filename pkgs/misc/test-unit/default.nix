{ buildRubyGem, ruby, test-unit-src }:
buildRubyGem {
  inherit ruby;

  pname = "test-unit";
  gemName = "test-unit";
  version = "flake";
  src = test-unit-src;
}
