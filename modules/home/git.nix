{ pkgs, ... }:
{
  home.packages = [
    pkgs.gh
  ];
  programs.git = {
    enable = true;
    difftastic.enable = true;
    lfs.enable = true;
    extraConfig = {
      merge.conflictStyle = "zdiff3";
      pull.ff = "only";
    };
    ignores = [ ".envrc" ".direnv" ];
  };
}
