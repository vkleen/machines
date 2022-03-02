{ userName, flake, lib, config, ...}: {
  users.users.${userName} = {
    extraGroups =
      [ "network" "xmpp" ];
    hashedPassword = lib.mkForce "$6$2SIRfdiWu53hQDQ2$slmSYSB6iTwH8ceR5vl8C5CwydvLtyLcJD/ocblcwFbYvkIRWtzj1yjSMra5p4R9PKhIGjC5SgrhyhItund5u/";
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
