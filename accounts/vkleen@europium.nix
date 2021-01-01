{ flake, lib, config, ...}: {
  users.users.vkleen = {
    extraGroups =
      [ "network" ];
  };
  home-manager.users.vkleen = lib.mkMerge (
    (with flake.userProfiles; [
      direnv git gnupg tmux zsh
      std-packages
    ])
  );
}
