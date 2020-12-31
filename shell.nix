{ pkgs ? import <nixpkgs> {} }:
let
  nixWithFlakes = pkgs.symlinkJoin {
    name = "nix-with-flakes";
    paths = [ pkgs.nixFlakes ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nix --add-flags '--option experimental-features "nix-command flakes ca-references"'
    '';
  };
in pkgs.mkShell {
  name = "nixos";
  nativeBuildInputs = with pkgs; [
    nixWithFlakes
    sops
  ];
}
