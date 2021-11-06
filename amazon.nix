{ pkgs, lib, config, ...}:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    package = pkgs.nixUnstable;
    buildCores = 16;
    maxJobs = 16;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';
  };

  systemd.services.print-host-key.script = lib.mkForce
    ''
      # Print the host public key on the console so that the user
      # can obtain it securely by parsing the output of
      # ec2-get-console-output.
      echo "-----BEGIN SSH HOST KEY-----" > /dev/console
      cat /etc/ssh/ssh_host_ed25519_key.pub >/dev/console
      echo "-----END SSH HOST KEY-----" > /dev/console
    '';
}
