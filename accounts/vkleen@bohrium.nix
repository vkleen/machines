{ flake, lib, config, ...}: {
  users.users.vkleen = {
    extraGroups =
      [ "network" "dialout" "audio" "video" "input" "wireshark" "adbusers" "bladerf" "kvm" "lp" ]
      ++ lib.optional (lib.elem "jack" config.system.profiles) "jackaudio";
  };
  home-manager.users.vkleen = lib.mkMerge (
    (with flake.userProfiles; [
      direnv git gnupg tmux zsh
      alacritty
      bluetooth
      browser
      desktop-packages
      gpg-agent
      kak
      kitty
      mpv
      neomutt
      obs
      redshift
      spacenav
      wayland
      weechat
      zathura
    ])
  );
}
