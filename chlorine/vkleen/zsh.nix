{config, nixos, pkgs, lib, ...}:

let
  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
    owner = "vkleen";
    repo = "zsh-syntax-highlighting";
    rev = "0.6.0";
    sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
  };

  pure-theme = pkgs.stdenv.mkDerivation {
    name = "zsh-pure-theme";
    src = pkgs.fetchFromGitHub {
      owner = "vkleen";
      repo = "pure";
      rev = "94e1067f25a602c29ac60d00737ebf974d5efcda";
      sha256 = "0776243j7657wphvkhr7982v27idvcvycwh82c11rqzax5fnl7jj";
    };
    preferLocalBuild = true;
    allowSubstitutes = false;
    buildCommand = ''
      mkdir -p $out
      install -m644 $src/async.zsh $out/async
      install -m644 $src/pure.zsh $out/prompt_pure_setup
    '';
  };

  git-subrepo = pkgs.fetchFromGitHub {
    owner = "vkleen";
    repo = "git-subrepo";
    rev = "a7ee886e0260e847dea6240eaa6278fb2f23be8a";
    sha256 = "0fih3bdabfbv0b2fckddiskpmvzwaq510rkzdyg12rdxcgihphqb";
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

  programs.zsh = {
    enable = true;
    inherit dotDir;
    enableCompletion = true;
    shellAliases = {
      l = "ls -l";
      la = "ls -la";
      lg = "l --git";
      ls = "${pkgs.exa}/bin/exa --color=always -F";
      ".." = "cd ..";
      p = "${pkgs.parallel}/bin/parallel";
      cat = "${pkgs.bat}/bin/bat";

      tmux = "${root-direnv} tmux";
    };
    initExtra = ''
      fpath+=( "${config.home.homeDirectory}/${pluginsDir}/pure" )
      PURE_PROMPT_SYMBOL='%(!.$.❯)'
      autoload -Uz promptinit; promptinit
      prompt pure

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

  home.file."${pluginsDir}/pure".source = pure-theme;
}
