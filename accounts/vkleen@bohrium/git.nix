{ pkgs, nixos, ... }:
{
  programs.git = {
    includes = [
      {
        condition = "gitdir:~/work/tweag/";
        path = "~/work/tweag/gitconfig";
      }
    ];
  };
}
