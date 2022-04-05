{
  description = "VKleen's flakey nixos configuration";

  inputs = {
    nixpkgs.url = sourcehut:~vkleen/nixpkgs/local?host=git.sr.ht.kleen.org;
    nixpkgs-power9.url = sourcehut:~vkleen/nixpkgs/local-power9?host=git.sr.ht.kleen.org;
    nixpkgs-riscv.url = sourcehut:~vkleen/nixpkgs/local-riscv?host=git.sr.ht.kleen.org;
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-rocm-power9 = {
      url = "github:vkleen/nixos-rocm";
      flake = false;
      inputs.nixpkgs.follows = "nixpkgs-power9";
    };
    freecad-src = {
      url = github:realthunder/FreeCAD;
      flake = false;
    };
    freecad-assembly3-src = {
      url = "github:realthunder/FreeCAD_assembly3";
      flake = false;
    };
    kicad-src = {
      url = "git+https://gitlab.com/kicad/code/kicad.git";
      flake = false;
    };
    hledger-src = {
      url = "github:vkleen/hledger";
      flake = false;
    };
    alacritty-src = {
      url = "github:alacritty/alacritty";
      flake = false;
    };
    emoji-fzf = {
      url = "github:vkleen/emoji-fzf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-riscv = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs-riscv";
    };
    nix-power9 = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs-power9";
    };
    rmfakecloud-src = {
      url = "github:ddvk/rmfakecloud";
      flake = false;
    };
    eseries-src = {
      url = "github:devbisme/eseries";
      flake = false;
    };
    dptrp1-src = {
      url = "github:vkleen/dpt-rp1-py/local";
      flake = false;
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
    };
    rmapi-src = {
      url = "github:juruen/rmapi";
      flake = false;
    };
    pacemaker-src = {
      url = "github:ClusterLabs/pacemaker";
      flake = false;
    };
    corosync-src = {
      url = "github:corosync/corosync";
      flake = false;
    };
    pcs-src = {
      url = "github:ClusterLabs/pcs";
      flake = false;
    };
    dacite-src = {
      url = "github:konradhalas/dacite";
      flake = false;
    };
    power-assert-src = {
      url = "github:ruby/power_assert";
      flake = false;
    };
    test-unit-src = {
      url = "github:test-unit/test-unit";
      flake = false;
    };
    bfd-src = {
      url = "github:vkleen/bfd";
      flake = false;
    };
    frr-src = {
      url = "github:FRRouting/frr?ref=frr-8.1";
      flake = false;
    };
    gobgp-src = {
      url = "github:osrg/gobgp";
      flake = false;
    };
    lego-src = {
      url = "github:vkleen/lego?ref=zerossl-accounts";
      flake = false;
    };
    hut-src = {
      url = git+https://git.sr.ht/~emersion/hut;
      flake = false;
    };

    utils = {
      url = github:vkleen/machine-utils;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.macname.follows = "macname";
    };

    macname = {
      url = sourcehut:~vkleen/macname?host=git.sr.ht.kleen.org;
    };
    macname-power9 = {
      url = sourcehut:~vkleen/macname?host=git.sr.ht.kleen.org;
      inputs.nixpkgs.follows = "nixpkgs-power9";
    };

    bfd-monitor = {
      url = sourcehut:~vkleen/bfd-monitor?host=git.sr.ht.kleen.org;
    };

    matrix-bifrost = {
      url = sourcehut:~vkleen/matrix-bifrost?host=git.sr.ht.kleen.org;
    };

    rmrl = {
      url = sourcehut:~vkleen/rmrl?host=git.sr.ht.kleen.org;
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    neovim-configuration = {
      url = sourcehut:~vkleen/neovim-configuration?host=git.sr.ht.kleen.org;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ...}@inputs:
    let
      inherit (builtins)
        attrNames
        attrValues
        elemAt
        fromJSON
        isNull
        pathExists
        toJSON
        toString
        ;
      inherit (inputs.nixpkgs) lib;
      utils = inputs.utils.lib;
      inherit (utils) recImport overrideModule;
      inherit (lib)
        composeManyExtensions
        concatLists
        concatMap
        concatStrings
        elem
        filterAttrs
        genAttrs
        getAttrs
        hasPrefix
        isDerivation
        listToAttrs
        mapAttrs
        mapAttrs'
        mapAttrsToList
        mkIf
        nameValuePair
        nixosSystem
        optionalAttrs
        recursiveUpdate
        splitString
        unique
        ;

      allSystems = [ "x86_64-linux" "aarch64-linux" "powerpc64le-linux" "riscv64-linux" ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = genAttrs allSystems;
      forAllSystems' = genAttrs supportedSystems;
      forAllUsers = genAttrs (unique (map accountUserName (attrNames self.nixosModules.accounts)));

      accountUserName = accountName:
        let
          accountName' = splitString "@" accountName;
        in elemAt accountName' 0;
      accountHostName = accountName:
        let
          accountName' = splitString "@" accountName;
        in elemAt accountName' 1;

      mkNixosConfiguration = addProfiles: dir: path: hostName: nixosSystem rec {
        specialArgs = {
          flake = self;
          flakeInputs = inputs;
          path = ./.;
        };
        modules =
          let
            defaultProfiles = with self.nixosModules.systemProfiles;
              [ core
              ];

            local = "${toString dir}/${path}";
            argsModule._module.args = {
              customUtils = utils;
              inherit hostName;
            };
            accountModules = attrValues (filterAttrs accountMatchesHost self.nixosModules.accounts);
            accountMatchesHost = n: _v: accountHostName n == hostName;
          in attrValues (filterAttrs (n: _v: !(elem n ["systemProfiles" "users" "userProfiles" "accounts"]))
                                     self.nixosModules
                        )
             ++ [ argsModule ]
             ++ defaultProfiles
             ++ addProfiles
             ++ [ local ]
             ++ accountModules;
      };

      mkSystemProfile = dir: path: profileName: {
        imports = [ "${toString dir}/${path}" ];
        config = {
          system.profiles = [profileName];
        };
      };

      defaultUserProfiles = userName: with self.nixosModules.userProfiles.${userName};
        [ core
        ];

      mkUserModule = dir: path: userName:
        overrideModule (import "${toString dir}/${path}")
                       (inputs: inputs // { inherit userName; })
                       (outputs:
                         { _file = "${toString dir}/${path}"; }
                         // outputs
                         // { imports = defaultUserProfiles userName ++ (outputs.imports or []); });

      mkUserProfile = userName: dir: path: profileName:
        let
          profileModule = overrideModule (import "${toString dir}/${path}")
                                         (inputs: inputs // { inherit userName; })
                                         (outputs:
                                           { _file = "${toString dir}/${path}"; }
                                           // outputs);
        in {
          imports = [ profileModule ];
          config = {
            users.users.${userName}.profiles = [ profileName ];
          };
        };

      mkAccountModule = dir: path: accountName:
        let
          userName = accountUserName accountName;
        in overrideModule
             (import "${toString dir}/${path}")
             (inputs: inputs // { inherit userName; })
             (outputs: { _file = "${toString dir}/${path}"; }
                       // outputs
                       // { imports = [ self.nixosModules.users.${userName} or
                                          ({...}: { imports = defaultUserProfiles userName; })
                                      ]
                                      ++ (outputs.imports or []); });

      activateNixosConfigurations = forAllSystems (system:
        filterAttrs (_: v: v != null)
          (mapAttrs' (hostName: nixosConfig: nameValuePair "${hostName}-activate" (
                          if system == nixosConfig.config.nixpkgs.pkgs.stdenv.targetPlatform.system
                            then { type = "app";
                                   program = "${nixosConfig.config.system.build.toplevel}/bin/switch-to-configuration";
                                  }
                            else null
                        )
                    )
                    self.nixosConfigurations));

      onlySystems = systems: overlay:
        final: prev: optionalAttrs (elem prev.stdenv.targetPlatform.system systems) (overlay final prev);

      forSystemsOverlay = defaultOverlay: overlays: final: prev: (overlays."${prev.stdenv.targetPlatform.system}" or defaultOverlay) final prev;

      utilOverlay =
        final: prev: {
          lib = prev.lib // {
            onlySystems = systems: overlay:
              optionalAttrs (elem prev.stdenv.targetPlatform.system systems) overlay;
            forSystemsOverlay = defaultOverlay: overlays: overlays."${prev.stdenv.targetPlatform.system}" or defaultOverlay;
            inherit allSystems supportedSystems;
          };
        };

      overlays =
        recImport { dir = ./overlays; } //
        {
          pkgs = self.overlay;
          nixpkgs-wayland = lib.composeExtensions
            (onlySystems supportedSystems inputs.nixpkgs-wayland.overlay)
            self.overlays.i3status-rust;
          poetry2nix = inputs.poetry2nix.overlay;
          nix = forSystemsOverlay inputs.nix.overlay
                                  (   { "powerpc64le-linux" = inputs.nix-power9.overlay; }
                                   // { "riscv64-linux" = inputs.nix-riscv.overlay; }
                                  );
          macname = forSystemsOverlay
            (_: _: {})
            (forAllSystems (system: _: _: { inherit (inputs.macname.packages."${system}") macname; })
             // { "powerpc64le-linux" = _: _: { inherit (inputs.macname-power9.packages."powerpc64le-linux") macname; }; });
          sources = final: prev: {
            inherit (inputs)
              alacritty-src
              bfd-src
              corosync-src
              dacite-src
              dptrp1-src
              eseries-src
              freecad-assembly3-src
              freecad-src
              frr-src
              gobgp-src
              hledger-src
              hut-src
              kicad-src
              lego-src
              pacemaker-src
              pcs-src
              power-assert-src
              rmapi-src
              rmfakecloud-src
              test-unit-src
            ;
          };
        };

      pkgsImport = system: pkgs:
        import pkgs {
          inherit system;
          overlays = [utilOverlay] ++ attrValues overlays;
          config = { allowUnfree = true; allowUnsupportedSystem = true; };
        };

      pkgsImportCross = localSystem: crossSystem: pkgs:
        import pkgs {
          inherit localSystem crossSystem;
          overlays = [utilOverlay] ++ attrValues overlays;
          config = { allowUnfree = true; allowUnsupportedSystem = true; };
        };

      pkgset =
           (forAllSystems' (s: pkgsImport s inputs.nixpkgs))
        // { "powerpc64le-linux" = (pkgsImport "powerpc64le-linux" inputs.nixpkgs-power9).extend (import inputs.nixos-rocm-power9); }
        // { "riscv64-linux" = pkgsImport "riscv64-linux" inputs.nixpkgs-riscv; };

      pkgSources = {
        local = inputs.nixpkgs;
        local-power9 = inputs.nixpkgs-power9;
        local-riscv = inputs.nixpkgs-riscv;
      };

      installerProfiles = system:
        let nixpkgs-path = pkgset.${system}.path;
            mkInstallerProfile = dir: path: {
              imports = [ "${toString dir}/${path}" ];
            };
        in mapAttrs (name: {path, output}: {
                       profile = mkInstallerProfile nixpkgs-path path;
                       inherit output;
                     })
          { cd-dvd = {
              path = "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
              output = out: out.config.system.build.isoImage;
            };
            netboot = {
              path = "nixos/modules/installer/netboot/netboot-minimal.nix";
              output = out: (pkgset.${system}.symlinkJoin {
                               name = "netboot";
                               paths = with out.config.system.build; [ netbootRamdisk kernel netbootIpxeScript ]; preferLocalBuild = true;
                             });
            };
          };

      installerConfig = if pathExists ./installer.nix
                        then "installer.nix"
                        else (if pathExists ./installer then "installer" else null);
      installers =
        let mkInstallers = system: mapAttrs (mkInstaller system) (installerProfiles system);
            mkInstaller = system: name: {profile, output}:
              output (mkNixosConfiguration [profile { config = { nixpkgs.system = system; }; }]
                                           ./.
                                           installerConfig
                                           "installer"
                     );
        in if !(isNull installerConfig)
           then { installers = forAllSystems (system: mkInstallers system); }
           else {};


        rtpPath = ".";

        addRtp = path: derivation:
          derivation // { rtp = "${derivation}/${path}"; };

        vimPlugin = pkgs: ref: vimPluginSubdir pkgs ref "";
        vimPluginSubdir = pkgs: ref: d: addRtp "${rtpPath}/${ref}" (pkgs.stdenv.mkDerivation {
          name = "vimplugin-${lib.strings.sanitizeDerivationName ref}";
          unpackPhase = ":";
          buildPhase = ":";
          configurePhase = ":";
          installPhase = ''
            runHook preInstall
            target="$out/${rtpPath}"
            mkdir -p "$target"
            cp -r "${inputs."${ref}".outPath}/${d}/"* "$target"
            runHook postInstall
          '';
        });
    in
      {
        nixosModules =
          let modulesAttrs = recImport { dir = ./modules; };
              systemProfiles = recImport rec { dir = ./system-profiles; _import = mkSystemProfile dir; };
              users = recImport rec { dir = ./users; _import = mkUserModule dir; };
              userProfiles = forAllUsers (userName: recImport rec { dir = ./user-profiles; _import = mkUserProfile userName dir; });
              accounts = recursiveUpdate rootAccounts (recImport rec { dir = ./accounts; _import = mkAccountModule dir; });
              rootAccounts = mapAttrs' (hostName: _: nameValuePair
                "root@${hostName}"
                ({...}:
                  { imports = [ self.nixosModules.users.root or
                                ({...}: { imports = defaultUserProfiles "root"; })
                              ];
                  }))
                self.nixosConfigurations;
          in modulesAttrs // { inherit systemProfiles users userProfiles accounts; };

        nixosConfigurations =
          recImport rec { dir = ./hosts; _import = mkNixosConfiguration [] dir; };

        homeManagerModules = recImport rec { dir = ./home-modules; };
        homeConfigurations = listToAttrs (concatLists (
          mapAttrsToList
            (hostname: nixosConfig:
              mapAttrsToList (username: configuration: nameValuePair "${username}@${hostname}"
                                                                     { inherit (configuration.home)
                                                                               activationPackage;
                                                                     })
                             nixosConfig.config.home-manager.users)
            self.nixosConfigurations));

        overlay = import ./pkgs; # Dummy system

        overlays = {
          inherit utilOverlay;
        } // overlays;

        legacyPackages = pkgset;

        packages = forAllSystems (system:
          let
            pkgs = pkgset."${system}";
            pkgNames = concatMap (o: attrNames (o pkgs pkgs)) (attrValues overlays);
          in filterAttrs (_: isDerivation) (getAttrs pkgNames pkgset."${system}"));

        apps = activateNixosConfigurations;

        devShell = forAllSystems' (system: import ./shell.nix ({
          pkgs = self.legacyPackages.${system};
          inherit (inputs.home-manager.packages.${system}) home-manager;
        } // (if inputs.agenix.packages ? ${system} then {
          inherit (inputs.agenix.packages.${system}) agenix;
        } else {})));

        defaultTemplate = {
          path = ./.;
          description = "A flakey nixos configuration";
        };

        checks = self.packages;
      } // installers;
}
