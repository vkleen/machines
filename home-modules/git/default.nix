{ config, pkgs, nixos, ... }:
let
  hub-wrapper = pkgs.writeShellScriptBin "hub" ''
    GITHUB_USER=vkleen GITHUB_TOKEN=$(${pkgs.gopass}/bin/gopass github/hub-token) ${pkgs.gitAndTools.hub}/bin/hub "$@"
  '';
  gh-wrapper = pkgs.writeShellScriptBin "gh" ''
    GH_USER=vkleen GH_TOKEN=$(${pkgs.gopass}/bin/gopass github/hub-token) ${pkgs.gh}/bin/gh "$@"
  '';
in {
  home.packages = [
    hub-wrapper
    gh-wrapper
    pkgs.ghq
    pkgs.glab
    pkgs.gitAndTools.git-crypt
    pkgs.gitAndTools.git-remote-gcrypt
    pkgs.gitAndTools.lab
  ];
  xdg.configFile."lab/lab.toml".source = (pkgs.formats.toml{}).generate "lab.toml" {
    core = {
      host = "https://gitlab.com";
      load_token = "${pkgs.gopass}/bin/gopass gitlab.com/pat";
      user = "vkleen";
    };
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.git;
    difftastic.enable = true;
    userName = "Viktor Kleen";
    userEmail = "viktor@kleen.org";
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_nitro_signing";
      signByDefault = true;
    };
    lfs.enable = true;
    extraConfig = {
      gpg = {
        format = "ssh";
      };
      init = {
        defaultBranch = "main";
      };
      color = {
        ui = true;
      };
      sendemail = {
        smtpServer = "${nixos.security.wrapperDir}/sendmail";
      };
      http = {
        sslcainfo = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
      gcrypt = {
        participants = "1FE9015A0610E43C74EFC813744138390330BB39";
        publish-participants = true;
      };
      github = {
        user = "vkleen";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        ff = "only";
      };
      ghq = {
        root = "~/src";
      };
    };
    ignores = [ ".envrc" ".direnv" ];
    aliases = {
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog =
        "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog =
        "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";
      recommit = "!git commit -eF $(git rev-parse --git-dir)/COMMIT_EDITMSG";
    };  };
}
