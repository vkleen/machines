{ pkgs, ...}:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      "freyr.1:d8VFt+9VtvwWAMKEGEERpZtWWh8Z3bDf+O2HrOLjBYQ="
      "ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org-1:reOmDDtgU13EasMsy993sq3AuzGmXwfSxNTYPfGf3Hc="
    ];

    buildCores = 18;
    maxJobs = 18;
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
    vim mosh tmux htop cachix
  ];
}
