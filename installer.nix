{ flake, pkgs, ... }: {
  imports = (with flake.nixosModules.systemProfiles; [
    latest-linux
    ssh
  ]);
  config = {
    boot = {
      zfs.enableUnstable = true;
      kernelParams = [ "console=ttyS0,115200n8" ];
    };

    networking.wireless.enable = false;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 # ssh
                        ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
      ];
    };

    systemd.services."sshd".wantedBy = ["multi-user.target"]; 

    #services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
      nvme-cli iotop mosh
    ];

    services.tcsd = {
      enable = true;
    };
  };
}
