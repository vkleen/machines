args@
{ lib
, pkgset
, pkgSources
, self
, utils
, home-manager
, ...
}:
let
  home = home-manager;
  inherit (utils) recImport;

  config = hostName:
    lib.nixosSystem {
      modules =
        let
          inherit (home.nixosModules) home-manager;
          inherit (self.nixosModules.profiles) core;

          global = {
            networking.hostName = hostName;
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;

            home-manager.useUserPackages = true;

            _module.args.pkgset = pkgset;
            _module.args.pkgSources = pkgSources;
          };

          local = import "${toString ./.}/${hostName}.nix" self;
        in
          [ core global local home-manager ];
    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in hosts
