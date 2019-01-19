{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    kexectools
  ];
}
