### https://nixos.org/channels/nixpkgs-unstable nixos
{ pkgs, lib, config, ...}:
let
  cache-url = "s3://vkleen-nix-cache?region=eu-central-1";
in
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    binaryCaches = [
      cache-url
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      "aws-vkleen-nix-cache-1:0mQ08qXrc6QAAXrQZic3R4plUs96tObJsiTwIOKYldU="
    ];

    buildCores = 2;
    maxJobs = 2;
  };
  networking = {
    firewall = {
      enable = true;
      checkReversePath = false;
      allowPing = true;
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
  };
  environment.systemPackages = with pkgs; [
    vim mosh tmux htop
  ];

  boot.binfmt.emulatedSystems = [
    "powerpc64le-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

  systemd.services.print-host-key.script = lib.mkForce
    ''
      # Print the host public key on the console so that the user
      # can obtain it securely by parsing the output of
      # ec2-get-console-output.
      echo "-----BEGIN SSH HOST KEY-----" > /dev/console
      cat /etc/ssh/ssh_host_ed25519_key.pub >/dev/console
      echo "-----END SSH HOST KEY-----" > /dev/console
    '';

  systemd.services.amazon-init.script = lib.mkForce
    ''
      echo "attempting to fetch configuration from EC2 user data..."

      export HOME=/root
      export PATH=${pkgs.lib.makeBinPath [ config.nix.package pkgs.systemd pkgs.gnugrep pkgs.git pkgs.gnutar pkgs.gzip pkgs.gnused config.system.build.nixos-rebuild]}:$PATH
      export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

      userData=/etc/ec2-metadata/user-data

      if [ -s "$userData" ]; then
        # If the user-data looks like it could be a nix expression,
        # copy it over. Also, look for a magic three-hash comment and set
        # that as the channel.
        if sed '/^\(#\|SSH_HOST_.*\)/d' < "$userData" | grep -q '\S'; then
          channels="$(grep '^###' "$userData" | sed 's|###\s*||')"
          while IFS= read -r channel; do
            echo "writing channel: $channel"
          done < <(printf "%s\n" "$channels")

          if [[ -n "$channels" ]]; then
            printf "%s" "$channels" > /root/.nix-channels
            nix-channel --update
          fi

          echo "setting configuration from EC2 user data"
          cp "$userData" /etc/nixos/configuration.nix
        else
          echo "user data does not appear to be a Nix expression; ignoring"
          exit
        fi
      else
        echo "no user data is available"
        exit
      fi

      nixos-rebuild switch
    '';
}
