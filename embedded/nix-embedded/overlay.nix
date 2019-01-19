{ lib, packages }:
self: super: let
  recoverPkgs = super: n: if n ? __nix_embedded_name
                          then { name = n.__nix_embedded_name;
                                 value = super."${n.__nix_embedded_name}";
                               }
                          else { name = "__nix_embedded_dummy_name"; value = {}; };

  super-names = lib.mapAttrs (k: _: { __nix_embedded_name = k; }) super;

  standard = lib.mapAttrs (_: lib.statically)
                          (builtins.listToAttrs
                            (map (recoverPkgs super)
                                 (packages super-names)));
in standard
