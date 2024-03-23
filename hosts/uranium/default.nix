{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "server";
    hostPlatform = "x86_64-linux";
  };
in
rec {
  system = lib.nixosSystem trilbyConfig {
    modules = with inputs.self.nixosModules; [
      server
    ]
    # ++ [
    #   ({ config, modulesPath, ... }: {
    #     imports = [ "${modulesPath}/installer/netboot/netboot.nix" ];
    #     config = {
    #       boot.kernelParams = [ "console=ttyS0" ];
    #       boot.uki.settings.UKI.Initrd = "${config.system.build.netbootRamdisk}/initrd";
    #     };
    #   })
    # ]
    ++ lib.findModulesList ./.
    ++ (lib.attrValues (lib.findModules ./accounts));
    # ++ (lib.attrValues (lib.findModules ../../accounts));
  };
  output = system.pkgs.linkFarm "uranium" [
    {
      name = "nixos.efi";
      path = "${system.config.system.build.uki}/nixos.efi";
    }
    {
      name = "toplevel";
      path = "${system.config.system.build.toplevel}";
    }
  ];
}

