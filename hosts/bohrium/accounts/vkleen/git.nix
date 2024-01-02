{ pkgs, config, nixosConfig, ... }:
let
  allowed-signers = pkgs.writeText "allowed_signers" ''
    viktor@kleen.org,viktor.kleen@tweag.io sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDf2T6h9DvuFhqLnTYhsdNqnuVWJCWWo8o95/5LHWchIAAAABHNzaDo=
    viktor@kleen.org,viktor.kleen@tweag.io ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqlMmfwU541oEojz+mJZzTrmy43T2W6pLldw2v++c3T
  '';
in
{
  home.packages = [
    pkgs.ghq
  ];

  programs.git = {
    userName = "Viktor Kleen";
    userEmail = "viktor@kleen.org";
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_github_sign";
      signByDefault = true;
    };
    extraConfig = {
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = builtins.toString allowed-signers;
      };
      init.defaultBranch = "main";
      color.ui = true;
      github.user = "vkleen";
      sendemail = {
        smtpServer = "${nixosConfig.security.wrapperDir}/sendmail";
      };
      ghq.root = "~/src";
    };
    includes = [
      {
        condition = "gitdir:~/work/tweag/";
        path = "~/work/tweag/gitconfig";
      }
    ];
  };
}
