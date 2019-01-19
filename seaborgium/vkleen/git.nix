{pkgs, ...}:
{
  imports = [
    ./secrets.nix
  ];
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
        smtpServer = "/run/wrappers/bin/sendmail";
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
  };
}
