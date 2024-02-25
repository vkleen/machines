{ pkgs, inputs, ... }:
{
  imports = with inputs.self.nixosModules.home; [
    bat
    direnv
    fish
    helix
    starship
    tmux
  ];

  config = {
    home.packages = with pkgs; [
      gnupg
      ripgrep
      tmate
      yq
    ];
  };

}
