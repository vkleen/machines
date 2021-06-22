{ pkgs, nixos, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.git;
    userName = "Viktor Kleen";
    userEmail = "viktor@kleen.org";
    signing = {
      key = "1FE9015A0610E43C74EFC813744138390330BB39";
      signByDefault = true;
    };
    extraConfig = {
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
        conflictStyle = "diff3";
      };
      pull = {
        ff = "only";
      };
    };
    delta = {
      enable = true;
      options = {
        features = "decorations line-numbers";
        whitespace-error-style = "22 reverse";
        plus-style = "syntax #003800";
        minus-style = "syntax #3f0001";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-stye = "bold yellow ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "cyan box ul";
        };
        line-numbers = {
          line-numbers-left-style = "cyan";
          line-numbers-right-style = "cyan";
          line-numbers-minus-style = 124;
          line-numbers-plus-style = 28;
        };
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
    };  };
}
