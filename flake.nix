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

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
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
      nixosConfigurations = lib.mapAttrs build
        (installers // hosts);
    } // lib.foreach cpus (evalCpu:
      let
        overlays = lib.attrValuesRecursive inputs.self.overlays;
        pkgs = import (lib.nixpkgs { hostCpu = evalCpu; }).outPath {
          system = "${evalCpu}-linux";
          config = { };
          inherit overlays;
        };
        tools = f: lib.flip lib.mapAttrsRecursive (lib.findModules ./tools)
          (_: v: f (import v {
            inherit inputs lib pkgs;
            system = "${evalCpu}-linux";
          }));
      in
      {
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
          tools = tools (v: v.package) // {
            inherit (inputs.macname.packages."${evalCpu}-linux") macname;
          };
        };

        devShells."${evalCpu}-linux" = tools (v: v.devShell) // {
          default = pkgs.mkShell {
            packages = [ pkgs.nixpkgs-fmt ];
          };
        };
      });
}
