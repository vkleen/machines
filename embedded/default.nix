let
  pkgs-path = import ../fetch-nixpkgs.nix;
  pkgs-args = {
    localSystem = {
      system = builtins.currentSystem;
    };
    crossSystem = {
      libc = "musl";
      config = "x86_64-linux-musl";
    };
    # crossSystem = {
    #   libc = "musl";
    #   config = "armv7l-linux-musleabihf";
    #   platform = {
    #     endian = "little";
    #     kernelArch = "arm";
    #     gcc = {
    #       arch = "armv7-a";
    #       fpu = "vfpv3-d16";
    #     };
    #   };
    # };
  };
in
  import ./nix-embedded {
    pkgsFun = import "${pkgs-path}/pkgs/top-level";
    inherit pkgs-args;
    modules = mod: with mod; [
      busybox
      cryptsetup
      dropbear
      kexec
      coreboot
    ];
  }
