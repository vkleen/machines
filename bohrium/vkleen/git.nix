{pkgs, nixos, ...}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Viktor Kleen";
    userEmail = "viktor@kleen.org";
    signing = {
      key = "1FE9015A0610E43C74EFC813744138390330BB39";
      signByDefault = true;
    };
    extraConfig = {
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
    };
    ignores = [ ".envrc" ".direnv" ];
    aliases = {
      lg = ''!"git lg1"'';
      lg1 = ''!"git lg1-specific --all"'';
      lg2 = ''!"git lg2-specific --all"'';
      lg3 = ''!"git lg3-specific --all"'';

      lg1-specific = ''log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' '';
      lg2-specific = ''log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n'''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' '';
      lg3-specific = ''log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n'''          %C(white)%s%C(reset)%n'''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)' '';
    };
  };
}
