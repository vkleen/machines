{ lib, ... }:
{
  findModules = dir: lib.pipe dir [
    builtins.readDir
    lib.attrsToList
    (lib.foldr
      ({ name, value }: acc:
        let
          fullPath = dir + "/${name}";
          isNixModule = lib.allTrue [
            (value == "regular")
            (lib.hasSuffix ".nix" name)
            (name != "default.nix")
          ];
          isDir = value == "directory";
          isDirModule = lib.allTrue [
            isDir
            (builtins.readDir fullPath ? "default.nix")
          ];
          module = lib.nameValuePair (lib.removeSuffix ".nix" name) (
            if isNixModule || isDirModule
            then fullPath
            else
              if isDir
              then lib.findModules fullPath
              else {}
          );
        in
        if module.value == {}
        then acc
        else acc ++ [ module ]
      ) [])
    lib.listToAttrs
  ];
}