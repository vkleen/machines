{ inputs
, lib ? inputs.nixpkgs.lib
, ...
}:
lib.makeExtensible (self:
  lib.pipe ./. [
    lib.filesystem.listFilesRecursive
    (lib.filter (file: lib.hasSuffix ".nix" file && file != ./default.nix))
    (builtins.map (file: import file { inherit inputs; lib = self; }))
    (lib.foldr lib.recursiveUpdate lib)
  ]
)