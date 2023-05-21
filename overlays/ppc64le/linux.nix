final: prev: {
  mkPower9LinuxPackages = linuxPackages: linuxPackages.extend
    (kfinal: kprev: {
      kernel = final.lib.makeOverridable
        (args:
          (kprev.kernel.override args).overrideAttrs (o: {
            installFlags = o.installFlags ++ [ "KBUILD_IMAGE=vmlinux.strip.gz" ];
            inherit (kprev.kernel) passthru;
          }))
        { };
    });
}
