{
  description = "VKleen's flakey nixos configuration";

  inputs = {
    nixpkgs.url = "github:vkleen/nixpkgs/local";
    nixpkgs-power9.url = "github:vkleen/nixpkgs/local-power9";
    nixpkgs-riscv.url = "github:vkleen/nixpkgs/local-riscv";
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-rocm-power9 = {
      url = "github:vkleen/nixos-rocm";
      flake = false;
    };
    freecad-src = {
      url = "github:realthunder/FreeCAD";
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
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim-flake.follows = "neovim-flake";
      };
    };
    neovide-src = {
      url = "github:Kethku/neovide";
      flake = false;
    };

    # Vim Plugins
    bufferline = { url = "github:akinsho/bufferline.nvim"; flake = false; };
    clever-f = { url = "github:rhysd/clever-f.vim"; flake = false; };
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    fterm = { url = "github:numtostr/FTerm.nvim"; flake = false; };
    gitsigns = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };
    lualine = { url = "github:hoob3rt/lualine.nvim"; flake = false; };
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    nvim-colorizer = { url = "github:norcalli/nvim-colorizer.lua"; flake = false; };
    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    nvim-selenized = { url = "github:jan-warchol/selenized"; flake = false; };
    nvim-treesitter-context = { url = "github:romgrk/nvim-treesitter-context"; flake = false; };
    nvim-ts-rainbow = { url = "github:p00f/nvim-ts-rainbow"; flake = false; };
    plenary-nvim = { url = "github:vkleen/plenary.nvim"; flake = false; };
    rust-tools = { url = "github:simrat39/rust-tools.nvim"; flake = false; };
    telescope-ghq = { url = "github:nvim-telescope/telescope-ghq.nvim"; flake = false; };
    telescope-lsp-handlers = { url = "github:gbrlsnchs/telescope-lsp-handlers.nvim"; flake = false; };
    telescope-zoxide = { url = "github:jvgrootveld/telescope-zoxide"; flake = false; };
    vim-vsnip-integ = { url = "github:hrsh7th/vim-vsnip-integ"; flake = false; };
    vim-vsnip = { url = "github:hrsh7th/vim-vsnip"; flake = false; };
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
        toString;
      inherit (inputs.nixpkgs) lib;
      utils = import ./utils { inherit lib; };
      inherit (utils) recImport overrideModule;
      inherit (lib)
        composeManyExtensions
        concatLists
        concatMap
        concatStrings
        elem
        filterAttrs
        genAttrs
        hasPrefix
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
        unique;

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "powerpc64le-linux" "riscv64-linux" ];
      forAllSystems' = genAttrs [ "x86_64-linux" "aarch64-linux" ];
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
             ++ [ inputs.agenix.nixosModules.age argsModule ]
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
          (mapAttrs' (hostName: nixosConfig:
                      if system == nixosConfig.config.nixpkgs.pkgs.stdenv.targetPlatform.system
                      then nameValuePair
                             "${hostName}-activate"
                             { type = "app";
                               program = "${nixosConfig.config.system.build.toplevel}/bin/switch-to-configuration";
                             }
                      else nameValuePair "${hostName}-activate" null
                    )
                    self.nixosConfigurations));

      overlays = recImport { dir = ./overlays; } //
        { pkgs = self.overlay;

          nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
          neovim-nightly = inputs.neovim-nightly.overlay;
          sources = _: _: {
            inherit (inputs)
              freecad-assembly3-src
              freecad-src
              hledger-src
              kicad-src
              neovide-src
            ;
          };
        };

      overlayPaths = system:
        recImport rec { dir = ./overlays; _import = (path: _name: "${toString dir}/${path}"); }
        // { pkgs = ./pkgs;
             nixpkgs-wayland = inputs.nixpkgs-wayland;
             neovim-nightly = inputs.neovim-nightly;

             sources = pkgset.${system}.writeText "sources.nix" ''
               _: _: {
                 freecad-assembly3-src = ${toString inputs.freecad-assembly3-src};
                 freecad-src = ${toString inputs.freecad-src};
                 hledger-src = ${toString inputs.hledger-src};
                 kicad-src = ${toString inputs.kicad-src};
                 neovide-src = ${toString inputs.neovide-src};
               }
             '';
           };

      pkgsImport = system: pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues overlays;
          config = { allowUnfree = true; allowUnsupportedSystem = true; };
        };

      pkgsImportCross = localSystem: crossSystem: pkgs:
        import pkgs {
          inherit localSystem crossSystem;
          overlays = attrValues overlays;
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
        in mapAttrs (name: {path, output}: {
                       profile = mkSystemProfile nixpkgs-path path "installer-${name}"; inherit output;
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


        rtpPath = "share/vim-plugins";

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
            cp -r "${inputs."${ref}".outPath}/${d}" "$target/${ref}"
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
          optionalAttrs (!(isNull installerConfig)) { installer = installerConfig; } //
          recImport rec { dir = ./hosts; _import = mkNixosConfiguration [] dir; };

        homeManagerModules = recImport rec { dir = ./home-modules; };

        overlay = import (overlayPaths "x86_64-linux").pkgs; # Dummy system

        overlays-path = forAllSystems (system:
          let
            pkgs = self.legacyPackages.${system};
            overlaysJSON = pkgs.writeText "overlays.json" (toJSON (overlayPaths system));
          in pkgs.writeText "overlays.nix" ''
            map (p: import p) (builtins.attrValues (builtins.fromJSON (builtins.readFile ${overlaysJSON})))
          '');

        legacyPackages = pkgset;

        apps = activateNixosConfigurations;

        vimPlugins = forAllSystems (system:
        let
          pkgs = self.legacyPackages.${system};
          subdir = n: d: {
            outPath = "${builtins.toString inputs."${n}".outPath}/${d}";
          };
        in genAttrs [
            "bufferline"
            "clever-f"
            "cmp-buffer"
            "cmp-nvim-lsp"
            "fterm"
            "gitsigns"
            "lualine"
            "nvim-cmp"
            "nvim-colorizer"
            "nvim-lspconfig"
            "nvim-treesitter-context"
            "nvim-ts-rainbow"
            "plenary-nvim"
            "rust-tools"
            "telescope-ghq"
            "telescope-lsp-handlers"
            "telescope-zoxide"
            "vim-vsnip"
            "vim-vsnip-integ"
          ] (vimPlugin pkgs) // {
            nvim-selenized = vimPluginSubdir pkgs "nvim-selenized" "editors/vim";
          });

        devShell = forAllSystems (system: import ./shell.nix {
          pkgs = self.legacyPackages.${system};
          inherit (inputs.agenix.packages.${system}) agenix;
        });

        defaultTemplate = {
          path = ./.;
          description = "A flakey nixos configuration";
        };
      } // installers;
}
