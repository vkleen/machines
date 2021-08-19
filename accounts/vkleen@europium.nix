{ userName, flake, lib, config, ...}: {
  users.users.${userName} = {
    extraGroups =
      [ "network" ];
  };
  home-manager.users.${userName} = lib.mkMerge (
    (with flake.homeManagerModules; [
      direnv
      git
      gnupg
      tmux
      zsh
    ])
  );
}
