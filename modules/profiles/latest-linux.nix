{ pkgs, lib, config, ... }:
let
  kernelPackages = pkgs.linuxKernel.packageAliases.linux_latest.extend
    (final: prev: lib.optionalAttrs pkgs.stdenv.hostPlatform.isPower64 {
      kernel = lib.makeOverridable
        (args:
          let
            kernel = prev.kernel.override args;
          in
          kernel.overrideAttrs (o: {
            # buildFlags = o.buildFlags ++ [ "modules" "zImage" ];
            # installFlags = o.installFlags ++ [ "KBUILD_IMAGE=$(boot)/zImage" ];
            # installTargets = [ "install" ];
            postFixup = (o.postFixup or "") + ''
              xz --stdout $out/vmlinux > vmlinux.xz
              mv vmlinux.xz $out/vmlinux
            '';
            inherit (kernel) passthru;
          }))
        { };
    });
in
{
  boot = { inherit kernelPackages; };
}
