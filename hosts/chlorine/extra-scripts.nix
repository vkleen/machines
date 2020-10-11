{ config, pkgs, ... }:
let
  update-boot = pkgs.writeShellScriptBin "update-boot" ''
    sudo cp $(realpath /nix/var/nix/profiles/system/kernel) /boot/
    sudo cp $(realpath /nix/var/nix/profiles/system/initrd) /boot/
    sudo tee /boot/cmdline >/dev/null <<EOF
      init=$(realpath /nix/var/nix/profiles/system/init) $(< /nix/var/nix/profiles/system/kernel-params)
    EOF
  '';
in {
  home-manager.users.vkleen = {
    home.packages = [
      update-boot
    ];
  };
}
