final: prev: {
  mkPower9LinuxPackages = linuxPackages: linuxPackages.extend
    (kfinal: kprev: {
      kernel = final.lib.makeOverridable
        (args:
          let
            kernel = kprev.kernel.override (args // {
              extraConfig = args.extraConfig or "" + ''
                EXPERT y
                KERNEL_DEBUG y
              '';
            });
          in
          kernel.overrideAttrs (o: {
            installFlags = o.installFlags ++ [ "KBUILD_IMAGE=vmlinux.strip.gz" ];
            inherit (kernel) passthru;
          }))
        { };
    });
}
