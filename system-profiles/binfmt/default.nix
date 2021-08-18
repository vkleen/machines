{ config, lib, pkgs, ... }:
{
  boot.binfmt = {
    emulatedSystems = [
      "powerpc64le-linux"
      "armv6l-linux"
      "armv7l-linux"
      "riscv64-linux"
      "aarch64-linux"
    ];
  };
}
