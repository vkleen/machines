{ inputs, trilby, lib, config, ... }:
let
  pkgs = lib.pkgsFor trilby;
in
{
  imports = with inputs.self.nixosModules; let
    trilby = inputs.self.nixosModules.trilby;
  in
  [
    trilby.profiles.console
    trilby.profiles.documentation
    trilby.profiles.getty
    trilby.profiles.kernel
    trilby.profiles.ssh
    trilby.profiles.zram
    trilby.profiles.zsh
    profiles.nix
    profiles.hostid
    profiles.sudo-rs
    profiles.users
  ];

  options = {
    nixpkgs.allowedUnfree = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    system.publicAddresses = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = ''
        Publicly routable IP addresses suitable for inclusion into networking.hosts
      '';
    };
  };

  config = {
    networking.hostName = trilby.name;
    system.macnameNamespace = "auenheim.kleen.org";

    system.nixos = lib.mkMerge [
      {
        label = "vkleen";
        distroId = "vkleen";
        distroName = "Trilby unstable";
      }
    ];

    nixpkgs = lib.mkMerge [
      {
        inherit (pkgs) overlays;
        inherit (trilby) hostPlatform;
        config.allowUnfreePredicate = p: lib.elem (lib.getName p) config.nixpkgs.allowedUnfree;
      }
      (lib.optionalAttrs (trilby.buildPlatform != trilby.hostPlatform) {
        inherit (trilby) buildPlatform;
      })
      (lib.optionalAttrs (trilby.variant or "" == "musl") {
        pkgs = pkgs.pkgsMusl;
      })
    ];

    environment.systemPackages = with pkgs; [
      file
      git
      jq
      nvd
      rsync
      tmux
      unzip
      wget
      zip
    ];

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    time.timeZone = lib.mkDefault "Etc/UTC";

    users.users.root.initialHashedPassword = "";

    system.stateVersion = "24.05";
  };
}
