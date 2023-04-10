{ lib, ... }:
{
  attrsToList = lib.mapAttrsToList lib.nameValuePair;

  attrValuesRecursive = lib.flip lib.pipe [
    (lib.mapAttrsToList
      (_: value:
        if lib.isAttrs value
        then lib.attrValuesRecursive value
        else value
      ))
    lib.flatten
  ];
}
