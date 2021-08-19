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
      bluetooth
      browser
      desktop-packages
      direnv
      git
      gnupg
      gpg-agent
      kak
      kitty
      mpv
      neomutt
      obs
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
}
