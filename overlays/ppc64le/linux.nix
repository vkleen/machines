final: prev: {
  power9LinuxPackages = final.linuxPackagesFor (final.zfsUnstable.latestCompatibleLinuxPackages.kernel.overrideAttrs (o: {
    inherit (final.zfsUnstable.latestCompatibleLinuxPackages.kernel) passthru;
    postFixup = (o.postFixup or "") + ''
      xz --stdout $out/vmlinux > vmlinux.xz
      mv vmlinux.xz $out/vmlinux
    '';
  }));
}
