{config, nixos, pkgs, lib, ...}:

let
  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
    owner = "vkleen";
    repo = "zsh-syntax-highlighting";
    rev = "f5d1be7ec2436cfa9d45dfc2bb72fb060eae650f";
    sha256 = "1k83lrcd8w699gfg060qahp8x2g5g20m0ikmpihgv5hkwdmc1df9";
  };

  git-subrepo = pkgs.fetchFromGitHub {
    owner = "vkleen";
    repo = "git-subrepo";
    rev = "a04d8c2e55c31931d66b5c92ef6d4fe4c59e3226";
    sha256 = "0n10qnc8kyms6cv65k1n5xa9nnwpwbjn9h2cq47llxplawzqgrvp";
  };

  dotDir = ".config/zsh";
  pluginsDir = "${dotDir}/plugins";

  root-direnv = "${pkgs.direnv}/bin/direnv exec /";
in {
  programs.jq.enable = true;
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

  programs.zsh = {
    enable = true;
    inherit dotDir;
    enableCompletion = true;
    shellAliases = {
      l = "ls -l";
      la = "ls -la";
      ls = "${pkgs.exa}/bin/exa -F";
      lg = "l --git";
      e = "e-in-current-ws";
      ".." = "cd ..";
      scratch = "editor-scratch";
      p = "${pkgs.parallel}/bin/parallel";
      cat = "${pkgs.bat}/bin/bat -p";

      tmux = "${root-direnv} tmux";
    };
    plugins = [{
      name = "powerlevel10k";
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      src = pkgs.zsh-powerlevel10k;
    }];
    initExtraBeforeCompInit = ''
      source "${config.home.homeDirectory}/${dotDir}/.p10k.zsh"
    '';
    initExtra = ''
      # export LS_COLORS="$LS_COLORS:ow=1;7;34:st=30;44:su=30;41"

      source "${git-subrepo}/.rc"
      source "${zsh-syntax-highlighting}/zsh-syntax-highlighting.zsh"

      bindkey "^B" backward-delete-char
      bindkey "^H" backward-char
      bindkey "^L" forward-char
      bindkey "^K" up-line-or-search
      bindkey "^J" down-line-or-search
      bindkey "^O" clear-screen
    '';
  };

  home.file."${dotDir}/.p10k.zsh".source = ./p10k.zsh;
}
