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

    interactiveShellInit = ''
      set -U fish_greeting "🐟"
      bind \ch backward-char
      bind \cj history-search-forward
      bind \ck history-search-backward
      bind \cl forward-char
      bind \co clear-screen

      set -U fish_color_normal cdd6f4
      set -U fish_color_command 89b4fa
      set -U fish_color_param f2cdcd
      set -U fish_color_keyword f38ba8
      set -U fish_color_quote a6e3a1
      set -U fish_color_redirection f5c2e7
      set -U fish_color_end fab387
      set -U fish_color_comment 7f849c
      set -U fish_color_error f38ba8
      set -U fish_color_gray 6c7086
      set -U fish_color_selection --background=313244
      set -U fish_color_search_match --background=313244
      set -U fish_color_option a6e3a1
      set -U fish_color_operator f5c2e7
      set -U fish_color_escape eba0ac
      set -U fish_color_autosuggestion 6c7086
      set -U fish_color_cancel f38ba8
      set -U fish_color_cwd f9e2af
      set -U fish_color_user 94e2d5
      set -U fish_color_host 89b4fa
      set -U fish_color_host_remote a6e3a1
      set -U fish_color_status f38ba8
      set -U fish_pager_color_progress 6c7086
      set -U fish_pager_color_prefix f5c2e7
      set -U fish_pager_color_completion cdd6f4
      set -U fish_pager_color_description 6c7086
    '';

    functions = {
      fish_command_not_found = "__fish_default_command_not_found_handler $argv";
    };
  };
}
