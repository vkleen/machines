{ override-rev ? null }:
let
  spec = builtins.fromJSON (builtins.readFile ./nixpkgs-src.json) // {
    ${if override-rev != null then "rev" else null} = override-rev;
  };
  src = let url = "https://github.com/${spec.owner}/${spec.repo}/archive/${spec.rev}.tar.gz";
      in if override-rev == null
         then import <nix/fetchurl.nix> {
           inherit url;
           inherit (spec) hash;
         }
         else builtins.fetchurl url;
  nixcfg = import <nix/config.nix>;
in builtins.derivation {
  system = builtins.currentSystem;
  name = "nixpkgs-unpacked";
  builder = builtins.storePath nixcfg.shell;
  inherit src;
  args = [
    (builtins.toFile "builder" ''
      $coreutils/mkdir $out
      cd $out
      $gzip -d < $src | $tar -x --strip-components=1
    '')
  ];
  coreutils = builtins.storePath nixcfg.coreutils;
  tar = builtins.storePath nixcfg.tar;
  gzip = builtins.storePath nixcfg.gzip;
}
