{ lib, ... }:
{
  attrsToList = lib.mapAttrsToList lib.nameValuePair;
}