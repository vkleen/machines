{ pkgs, config, lib, pkgSources, ... }:
{
  imports = [
    ../../secrets/vkleen.nix
  ];

  config = lib.mkMerge [
    {
      users.users.vkleen = {
        group = "users";
        extraGroups = [ "wheel" "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "lp" ];
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
        let args = {
                     inherit pkgs lib;
                     config = config.home-manager.users.vkleen;
                     nixos = config;
                   };
            profiles = builtins.map (x: import x args);
        in lib.mkMerge (
          [{ programs.home-manager = {
              enable = true;
            };
            manual.manpages.enable = true;
            _module.args.pkgsPath = lib.mkForce pkgSources.local;
            _module.args.pkgs = lib.mkForce pkgs;
          }] ++ (profiles [
            ../profiles/alacritty
            ../profiles/bluetooth
            ../profiles/browser
            ../profiles/direnv
            ../profiles/emacs
            ../profiles/git
            ../profiles/gpg
            ../profiles/kak
            ../profiles/kitty
            ../profiles/mpv
            ../profiles/redshift
            ../profiles/tmux
            ../profiles/wayland
            ../profiles/weechat
            ../profiles/zsh
          ])
          ++ [ (lib.mkIf (config.system.configuration-type == "desktop")
                         (import ../profiles/desktop-packages args)
               ) ]
        );
    }
    ];
}
