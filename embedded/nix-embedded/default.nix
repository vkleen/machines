{ pkgsFun, pkgs-args ? {}, modules ? _: [] }:

let lib' = (pkgsFun pkgs-args).lib;
    lib = lib' // (import ./lib.nix { lib = lib'; });
    moduleArgs = { inherit lib; inherit (nixpkgs) buildPackages; };

    mergeModules = ms:
      let toFix = lib.foldl' (lib.flip lib.extends) (self: {})
                             (map (f: f moduleArgs) ms);
      in lib.fix' toFix;


    available-modules = (import ./modules.nix { inherit lib; });
    available-modules-keyed = lib.mapAttrs (k: m: { key = k; module = m; }) available-modules;

    closeModules = ms: args:
      builtins.genericClosure {
        startSet = ms available-modules-keyed;
        operator = m:
          ((m.module args {} {}).requires or (_: [])) available-modules-keyed;
      };

    unpack = map (m: m.module);

    configuration = mergeModules (unpack (closeModules modules moduleArgs));
    pkgs-args' = pkgs-args // {
      overlays = [ (import ./overlay.nix { inherit (configuration) packages; inherit lib; })
                 ] ++ configuration.overlays
                   ++ (if pkgs-args ? overlays then pkgs-args.overlays else []);
    };
    nixpkgs = pkgsFun pkgs-args';
in {
  inherit nixpkgs configuration lib;
}
