{ pkgs, ... }:
let update-boot = pkgs.writeScriptBin "update-boot" ''
      #!${pkgs.stdenv.shell}
      sudo cp $(realpath /nix/var/nix/profiles/system/kernel) /boot/
      sudo cp $(realpath /nix/var/nix/profiles/system/initrd) /boot/
      sudo tee /boot/cmdline <<EOF
        init=$(realpath /nix/var/nix/profiles/system/init) $(< /nix/var/nix/profiles/system/kernel-params
      EOF
    '';
in {
  home.packages = [
    update-boot
  ];
}
