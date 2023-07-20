{ inputs, lib, ... }:
{
  nixpkgs = { hostCpu, evalCpu ? hostCpu }:
    let
      hostPlatform = "${hostCpu}-linux";
      evalPlatform = "${evalCpu}-linux";
      nixpkgs =
        let
          nixpkgs-patched = inputs.nixpkgs.legacyPackages.${evalPlatform}.applyPatches {
            name = "nixpkgs";
            src = inputs.nixpkgs;
            patches = [ ../nixpkgs-power9.patch ];
          };
          nixpkgs-power9 = inputs.nixpkgs.lib.fix
            (self:
              (import "${nixpkgs-patched}/flake.nix").outputs {
                inherit self;
              }) // { outPath = "${nixpkgs-patched}"; };
        in
          {
            "powerpc64le" = nixpkgs-power9;
          }."${hostPlatform}" or inputs.nixpkgs;
    in
    nixpkgs;

  nixosConfig = lib.makeOverridable (
    { name ? null
    , hostCpu
    , evalCpu ? hostCpu
    , modules
    , formats ? [ "toplevel" ]
    }@args:
    rec {
      inherit name formats hostCpu evalCpu;
      hostPlatform = "${hostCpu}-linux";
      evalPlatform = "${evalCpu}-linux";
      nixpkgs = lib.nixpkgs { inherit hostCpu evalCpu; };
      specialArgs = {
        inherit lib;
        inputs = inputs // {
          inherit nixpkgs;
        };
        system = {
          inherit name hostCpu hostPlatform;
          computeHostId = inputs.macname.computeHostId.${evalPlatform};
        };
      };
      modules = [ inputs.self.nixosModules.profiles.core ] ++ args.modules;
    }
  );
}
