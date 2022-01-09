{ userName, flake, lib, config, ...}: {
  users.users.${userName} = {
    extraGroups =
      [ "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "lp" ]
      ++ lib.optional (lib.elem "jack" config.system.profiles) "jackaudio"
      ++ lib.optional (lib.elem "docker" config.system.profiles) "docker";
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
      neovim
      pass
      redshift
      spacenav
      std-packages
      tmux
      wayland
      weechat
      zathura
      zsh
    ])
  );
  age.secrets."dptrp1" = {
    file = ../secrets/dptrp1.age;
    owner = "vkleen";
  };
  age.secrets."dptrp1.key" = {
    file = ../secrets/dptrp1.key.age;
    owner = "vkleen";
  };
}
