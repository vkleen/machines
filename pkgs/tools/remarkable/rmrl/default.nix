{ poetry2nix, rmrl-src }:
poetry2nix.mkPoetryApplication {
  projectDir = ./.;
  src = rmrl-src;
  patches = [ ./cli.patch ];
}
