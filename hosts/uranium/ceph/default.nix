{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ceph ];

  services.ceph = {
    enable = false;
    global = {
      fsid = "9e9cb959-16c4-49ac-a4b0-61eabc409035";
      monHost = "v2:127.0.0.206:3300/0";
      monInitialMembers = "actinium";
      clusterNetwork = "127.0.0.0/24";
      publicNetwork = "127.0.0.0/24";
    };

    extraConfig = {
      "auth allow insecure global id reclaim" = "false";
    };

    mon = {
      enable = true;
      daemons = [ "actinium" ];
      extraConfig = {
        "ms bind msgr1" = "false";
        "mgr initial modules" = "iostat";
      };
    };

    mgr = {
      enable = true;
      daemons = [ "actinium" ];
      extraConfig = {
        "ms bind msgr1" = "false";
      };
    };

    mds = {
      enable = true;
      daemons = [ "actinium" ];
      extraConfig = {
        "ms bind msgr1" = "false";
      };
    };

    osd = {
      enable = true;
      daemons = [
        "0"
        "1"
        "2"
        "3"
      ];
    };
  };

  environment.persistence."/persist" = {
    directories = [
      { directory = "/var/lib/ceph"; user = "ceph"; group = "ceph"; mode = "0700"; }
    ];
    files = [
      { file = "/etc/ceph/ceph.client.admin.keyring"; parentDirectory = { user = "ceph"; group = "ceph"; mode = "0700"; }; }
      { file = "/etc/ceph/ceph.client.actinium.keyring"; parentDirectory = { user = "ceph"; group = "ceph"; mode = "0700"; }; }
    ];
  };
}
