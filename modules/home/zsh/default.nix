{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    zsh-completions
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      pager = "less -FR";
    };
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      source "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
      source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      source "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/lib/zsh-ls-colors/ls-colors.zsh"

      source ${./init.sh}
    '';

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat -p";
      l = "ls -l";
      la = "ls -la";
      ls = "${pkgs.lsd}/bin/lsd --icon-theme unicode --date relative -F";
      lt = "tree";
      tree = "ls --tree";
      ".." = "cd ..";
    };
  };
}
