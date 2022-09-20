{ pkgs, nixos, ... }:
let
  allowed-signers = pkgs.writeText "allowed_signers" ''
    viktor@kleen.org,viktor.kleen@tweag.io sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDf2T6h9DvuFhqLnTYhsdNqnuVWJCWWo8o95/5LHWchIAAAABHNzaDo=
  '';
in {
  programs.git = {
    extraConfig.gpg.ssh.allowedSignersFile = builtins.toString allowed-signers;
    includes = [
      {
        condition = "gitdir:~/work/tweag/";
        path = "~/work/tweag/gitconfig";
      }
    ];
  };
}
