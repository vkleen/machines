{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.zsh-completions
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidgetOptions = [
      "--preview 'echo {}'"
      "--preview-window down:3:hidden:wrap"
      "--bind '?:toggle-preview'"
      "--bind 'ctrl-j:down'"
      "--bind 'ctrl-k:up'"
    ];
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
    fileWidgetOptions = [
      "--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    ];
    defaultCommand = "${pkgs.ripgrep}/bin/rg --files --no-ignore --hidden --follow --glob '!.git/*'";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      pager = "less -FR";
    };
  };

  programs.zoxide = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    shellAliases = {
      l = "ls -l";
      la = "ls -la";
      ls = "${pkgs.lsd}/bin/lsd --icon-theme unicode --date relative -F";
      lt = "ls --tree";
      ".." = "cd ..";
      p = "${pkgs.parallel}/bin/parallel";
      cat = "${pkgs.bat}/bin/bat -p";
      root-direnv = "${pkgs.direnv}/bin/direnv exec /";
      tmux = "root-direnv tmux";
    };

    initExtraBeforeCompInit = ''
      source "${config.home.homeDirectory}/.p10k.zsh"
    '';
    initExtra = ''
      source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/lib/zsh-ls-colors/ls-colors.zsh"
    
      # Pretty colours in less command
      export LESS_TERMCAP_mb=$'\E[01;31m'
      export LESS_TERMCAP_md=$'\E[01;38;5;74m'
      export LESS_TERMCAP_me=$'\E[0m'
      export LESS_TERMCAP_se=$'\E[0m'
      export LESS_TERMCAP_so=$'\E[38;5;246m'
      export LESS_TERMCAP_ue=$'\E[0m'
      export LESS_TERMCAP_us=$'\E[04;38;5;146m'

      bindkey "^A" beginning-of-line
      bindkey "^E" end-of-line
      bindkey "^B" backward-delete-char
      bindkey "^H" backward-char
      bindkey "^L" forward-char
      bindkey "^K" up-line-or-search
      bindkey "^J" down-line-or-search
      bindkey "^O" clear-screen
      
      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      
      # preview directory's content with exa when completing cd
      zstyle ':fzf-tab:complete:*:*' fzf-preview '${pkgs.exa}/bin/exa -1 --color=always $realpath'
      
      # switch group using `,` and `.`
      zstyle ':fzf-tab:*' switch-group ',' '.'
      
      # give a preview of commandline arguments when completing `kill`
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
        '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

      setopt autocd
    '';
  };

  home.file.".p10k.zsh".source = ./p10k.zsh;
}
