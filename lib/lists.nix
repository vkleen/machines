{ lib, ... }:
{
  foreach = xs: f: lib.foldr lib.recursiveUpdate {} (builtins.map f xs);

  allTrue = lib.all lib.id;
}