{ userName, pkgs, flake, lib, config, ...}: let
  hut = pkgs.runCommand "hut-wrapper" {
    buildInputs = [ pkgs.makeWrapper ];
  }''
    makeWrapper ${pkgs.hut}/bin/hut $out/bin/hut \
      --add-flags "--config /run/agenix/hut"
  '';
in {
  users.users.${userName} = {
    extraGroups =
      [ "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "lp" ]
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
      { home.packages = [ pkgs.hut ]; }
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
  age.secrets."hut" = {
    file = ../../secrets/sourcehut/hut-config.age;
    owner = "vkleen";
  };
}
