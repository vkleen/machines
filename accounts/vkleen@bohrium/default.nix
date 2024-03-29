{ userName, pkgs, flake, lib, config, ...}: {
  users.users.${userName} = {
    extraGroups =
      [ "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "libvirtd" "lp" "scanner" ]
      ++ lib.optional (lib.elem "jack" config.system.profiles) "jackaudio"
      ++ lib.optional (lib.elem "docker" config.system.profiles) "docker";
  };
  home-manager.extraSpecialArgs = {
    inherit flake;
  };
  home-manager.users.${userName} = lib.mkMerge (
    (with flake.homeManagerModules; [
      alacritty
      browser
      desktop-packages
      direnv
      dptrp1
      git
      gnupg
      gpg-agent
      kitty
      mpv
      neomutt
      flake.inputs.neovim-configuration.homeManagerModules.${config.nixpkgs.system}.neovim-config
      pass
      redshift
      spacenav
      std-packages
      tmux
      wayland
      weechat
      zathura
      zsh
      { neovim-config.enable = true; }
      { xdg.configFile = {
        "wireplumber" = {
          source = ./wireplumber;
          recursive = true;
          onChange = ''
            ${pkgs.systemd}/bin/systemctl --user try-restart wireplumber
          '';
        };
      }; }
      { home.packages = [ pkgs.hut ];
        xdg.configFile = {
          "hut/config".text = ''
            instance "sr.ht.kleen.org" {
                access-token-cmd pass sr.ht.kleen.org/hut-token
            }
          '';
        };
      }
      {
        home.packages = [ pkgs.jrnl pkgs.helvum pkgs.nix-output-monitor ];
      }
      (import ./vdirsyncer.nix)
      (import ./khal.nix)
      (import ./todoman.nix)
      (import ./gmail.nix)
      (import ./spotify.nix)
      (import ./git.nix)
    ])
  );
  age.secrets."dptrp1" = {
    file = ../../secrets/dptrp1.age;
    owner = "vkleen";
  };
  age.secrets."dptrp1.key" = {
    file = ../../secrets/dptrp1.key.age;
    owner = "vkleen";
  };
  age.secrets."radicale/client_cert.pem" = {
    file = ../../secrets/radicale/client_cert.pem.age;
    owner = "vkleen";
  };
}
