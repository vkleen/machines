{ config, pkgs, ... }:
{
  services.ceph = {
    enable = true;
    global = {
      fsid = "9e9cb959-16c4-49ac-a4b0-61eabc409035";
      monHost = "127.0.0.206";
      clusterName = "127.0.0.0/24";
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/ceph"
  ];
}
