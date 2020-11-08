{ pkgs, config, lib, pkgSources, ... }:
{
  imports = [
    ../../secrets/vkleen.nix
  ];

  config = lib.mkMerge [
    {
      users.users.vkleen = {
        group = "users";
        extraGroups = [ "wheel" "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "lp" ] ++
          lib.optional (lib.any (x: x == "jack") config.system.extra-profiles) "jackaudio";
        createHome = true;
        home = "/home/vkleen";
        isNormalUser = true;
        shell = "${pkgs.zsh}/bin/zsh";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
        ];
        uid = 1000;
      };

      home-manager.users.vkleen =
        let profiles = builtins.map (x: import x);
        in lib.mkMerge (
          [{ programs.home-manager = {
              enable = true;
            };
            manual.manpages.enable = true;
            _module.args.pkgsPath = lib.mkForce pkgSources.local;
            _module.args.pkgs = lib.mkForce pkgs;
            _module.args.nixos = config;
          }] ++ (profiles [
            ../profiles/direnv
            ../profiles/git
            ../profiles/gnupg
            ../profiles/kak
            ../profiles/tmux
            ../profiles/zsh
          ])
          ++ [ (lib.mkIf (config.system.configuration-type != "server") (lib.mkMerge (profiles [
                 ../profiles/std-packages
               ])))]
          ++ [ (lib.mkIf (config.system.configuration-type == "desktop") (lib.mkMerge (profiles [
                 ../profiles/alacritty
                 ../profiles/bluetooth
                 ../profiles/browser
                 ../profiles/desktop-packages
                 ../profiles/gpg-agent
                 ../profiles/kitty
                 ../profiles/mpv
                 ../profiles/neomutt
                 ../profiles/obs
                 ../profiles/redshift
                 ../profiles/spacenav
                 ../profiles/wayland
                 ../profiles/weechat
                 ../profiles/zathura
               ])))]
        );
    }
    ];
}
