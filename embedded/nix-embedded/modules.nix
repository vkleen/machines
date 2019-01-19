{ lib }:
let mkModule = m: args: self: super:
                 let m' = m args self super;
                 in lib.attrsets.recursiveUpdate super {
                   packages = pkgs: (lib.attrByPath ["packages"] (_: []) m') pkgs ++
                                    (lib.attrByPath ["packages"] (_: []) super) pkgs;
                   overlays = (lib.attrByPath ["overlays"] [] m') ++
                              (lib.attrByPath ["overlays"] [] super);
                 } // (lib.attrsets.filterAttrs (n: _: n != "packages" && n != "overlays") m');
in lib.mapAttrs' (n: v: lib.nameValuePair
                          (lib.removeSuffix ".nix" n)
                          (mkModule v))
                 (lib.allNixFilesIn ./modules)
