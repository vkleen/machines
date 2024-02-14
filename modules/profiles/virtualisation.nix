{ pkgs, lib, trilby, ... }:
let
  ovmfCpus = [
    "x86_64"
    "i686"
    "aarch64"

  ];
in
{
  config = lib.mkMerge [

    {
      virtualisation = {
        podman = {
          enable = true;
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
        libvirtd = {
          enable = true;
          onBoot = "ignore";
          onShutdown = "shutdown";
          qemu = {
            ovmf = lib.mkMerge [
              (lib.mkIf
                (builtins.elem trilby.hostSystem.cpu.name ovmfCpus)
                {
                  enable = true;
                  packages = [ pkgs.OVMFFull.fd ];
                })
              (lib.mkIf (!builtins.elem trilby.hostSystem.cpu.name ovmfCpus) {
                enable = lib.mkForce false;
                packages = lib.mkForce [ ];
              })
            ];
            runAsRoot = false;
          };
        };
        spiceUSBRedirection.enable = true;
      };

      environment.systemPackages = with pkgs; [
        fuse-overlayfs
        # libguestfs # XXX: re-enable this once ocaml 5.2 is released and in nixpkgs
        podman-compose
        spice-vdagent
        swtpm
      ];

      boot.kernelModules = lib.mkIf
        (builtins.elem trilby.hostSystem.cpu.name [
          "x86_64"
          "i686"
        ]) [ "kvm-amd" "kvm-intel" ];
    }
    (lib.mkIf (trilby.hostSystem.cpu.name == "powerpc64le") {
      systemd.services.virtchd = {
        path = lib.mkForce [ ]; # This will fail at runtime, but cloud-hypervisor isn't a thing on powerpc64le anyways
      };
    })
  ];

}
