{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    fd
  ];

  programs.bat.enable = true;

  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat -p";
      l = "ls -l";
      la = "ls -la";
      ls = "${pkgs.lsd}/bin/lsd --icon-theme unicode --date relative -F";
      lt = "tree";
      tree = "ls --tree";
      ".." = "cd ..";
    };

    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];

    shellInit = ''
      set -U fish_greeting "🐟"
      bind \ch backward-char
      bind \cj history-search-forward
      bind \ck history-search-backward
      bind \cl forward-char
      bind \co clear-screen
    '';

    functions = {
      fish_command_not_found = "__fish_default_command_not_found_handler $argv";
    };
  };
}
