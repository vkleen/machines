{ flake, pkgs, ... }: {
  config = {
    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_5_14;
      zfs.enableUnstable = true;
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
  };
}
