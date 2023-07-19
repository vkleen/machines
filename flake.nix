{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    macname = {
      url = "github:vkleen/macname";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/17198cf5ae27af5b647c7dac58d935a7d0dbd189";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      cpus = [ "x86_64" "aarch64" "riscv64" "powerpc64le" ];

      hosts = lib.mapAttrs
        (n: v: (import v {
          inherit lib inputs;
        }).override { name = n; })
        (lib.findModules ./hosts);

      installers = lib.foreach cpus (hostCpu: {
        "installer-${hostCpu}" = lib.nixosConfig {
          name = "hydrogen";
          inherit hostCpu;
          modules =
            [
              {
                system.macnameNamespace = "nixos-installers.kleen.org";
                system.stateVersion = "23.05";
              }
              {
                users.users.root.hashedPassword = "";
                boot.loader.grub.device = "nodev";
              }
            ] ++ lib.attrValues {
              inherit (inputs.self.nixosModules)
                chrony
                doas
                latest-linux
                nix
                ssh
                ;
            };
        };
      });

      build = cfg: cfg.nixpkgs.lib.nixosSystem {
        inherit (cfg) specialArgs modules;
      };

      formats = lib.mapAttrsRecursive (_: v: import v) (lib.findModules ./formats);

      formatAttribute = prefix: format:
        if format != "toplevel" then
          "${prefix}-${format}"
        else
          prefix;
    in
    {
      inherit lib;
      nixosModules = lib.findModules ./modules;
      overlays = lib.mapAttrsRecursive (_: v: import v) (lib.findModules ./overlays);
    } // lib.foreach cpus (evalCpu: {
      packages."${evalCpu}-linux" = (
        lib.foreach (lib.attrValues installers)
          (installer: lib.foreach (lib.attrNames formats) (format: {
            "${formatAttribute "installer-${installer.hostCpu}" format}" = (build (installer.override {
              formats = [ format ];
              inherit evalCpu;
              modules = installer.modules ++ [ formats.${format} ];
            })).config.system.build.${format};
          }))

      ) //
      (
        lib.foreach (lib.attrValues hosts)
          (host: lib.foreach (host.formats ++ [ "pkgs" ]) (format: {
            "${formatAttribute host.name format}" = (build (host.override {
              inherit evalCpu;
              modules = host.modules ++ [ formats.${format} ];
            })).config.system.build.${format};
          }))
      ) // {
        inherit (inputs.macname.packages."${evalCpu}-linux") macname;
      };
    }) //
    {
      nixosConfigurations = lib.mapAttrs build
        (installers // hosts);
    };
}
