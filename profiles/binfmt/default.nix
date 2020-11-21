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
    registrations = {
      aarch64-linux = {
        fixBinary = true;
      };
      qemu-aarch64 = {
        magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
        mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
        fixBinary = true;
        interpreter = (lib.systems.elaborate { system = "aarch64-linux"; }).emulator pkgs;
      };
    };
  };
}
