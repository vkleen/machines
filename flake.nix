{
  description = "VKleen's flakey nixos configuration";

  inputs = {
    nixpkgs.url = "github:vkleen/nixpkgs/local";
    nixpkgs-power9.url = "github:vkleen/nixpkgs/local-power9";
    nixpkgs-riscv.url = "github:vkleen/nixpkgs/local-riscv";
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
      url = "github:realthunder/FreeCAD?rev=ecadd72902e5eab3b44ecb25b30c3dbcafe67e5e";
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
      url = "github:Kethku/neovide?rev=8a7c2a00dc4be834215e3f21f5a0c9dd53646998";
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

    macname = {
      url = "github:vkleen/macname";
    };
    macname-power9 = {
      url = "github:vkleen/macname";
      inputs.nixpkgs.follows = "nixpkgs-power9";
    };

    rmrl = {
      url = "github:vkleen/rmrl";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
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
        toString
        ;
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
          neovim-nightly = onlySystems supportedSystems (final: prev: {
            neovim-unwrapped = (inputs.neovim-nightly.overlay final prev).neovim-unwrapped;
          });
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
              dptrp1-src
              eseries-src
              freecad-assembly3-src
              freecad-src
              hledger-src
              kicad-src
              neovide-src
              rmapi-src
              rmfakecloud-src
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
