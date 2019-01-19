let
  pkgs-path = import ./fetch-nixpkgs.nix;
  lib = import "${pkgs-path}/lib";

  nixpkgs-x86_64 = args: import "${pkgs-path}/pkgs/top-level" ({
    crossSystem = null;
    localSystem = {
      system = "x86_64-linux";
      platform = lib.systems.platforms.pc64;
    };
  } // args);

  all-overlays-in = dir: with builtins; with lib;
    let allNixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
                                      (filterAttrs (name: _: hasSuffix ".nix" name)
                                      (readDir dir));
    in attrValues (allNixFilesIn dir);

  seaborgium-pkgs-args = {
      crossSystem = null;
      localSystem = {
        system = "x86_64-linux";
        platform = lib.systems.platforms.pc64;
      };
      config = { allowUnfree = true;
                 retroarch.enableHiganSFC = true;
                 android_sdk.accept_license = true;
               };
      overlays = all-overlays-in ./seaborgium/overlays;
    };
  seaborgium-pkgs = import "${pkgs-path}/pkgs/top-level" seaborgium-pkgs-args;
  seaborgium = (import "${pkgs-path}/nixos/lib/eval-config.nix" {
    inherit (seaborgium-pkgs.stdenv.hostPlatform) system;
    modules = [ ({lib,...}: {
                  config.nixpkgs.pkgs = lib.mkForce seaborgium-pkgs;
                })
                (import ./seaborgium/configuration.nix)
              ];
  }).config.system.build;

  freyr = (nixpkgs-x86_64 {}).nixos (import ./freyr/configuration.nix pkgs-path);

  samarium = (nixpkgs-x86_64 {
    overlays = all-overlays-in ./samarium/overlays;
  }).nixos (import ./samarium/configuration.nix pkgs-path);

  installer = (nixpkgs-x86_64 {}).nixos ({pkgs, lib, ...}: {
    imports = [
      "${pkgs-path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs = {
      enableUnstable = false;
      forceImportRoot = false;
      forceImportAll = false;
    };
    networking.hostId = "9c4940eb";
    environment.etc.machine-id.text = "9c4940eb9b564dd759092e215bcbc157";
  });

  nixpkgs-ppc64 = args: import "${pkgs-path}/pkgs/top-level" ({
    crossSystem = null;
    localSystem = {
      system = "powerpc64le-linux";
      platform = lib.systems.platforms.powernv;
    };
  } // args);
  chlorine = (nixpkgs-ppc64 {
    overlays = all-overlays-in ./chlorine/overlays;
  }).nixos (import ./chlorine/configuration.nix);
in {
  inherit pkgs-path;
  seaborgium = seaborgium.toplevel;
  inherit seaborgium-pkgs;
  freyr = freyr.toplevel;
  samarium = samarium.toplevel;

  installer-iso = installer.isoImage;

  chlorine-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le;
  chlorine-musl-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le-musl;
  chlorine-pkgs = nixpkgs-ppc64 {
    overlays = all-overlays-in ./chlorine/overlays;
  };
  chlorine = chlorine.toplevel;
}
