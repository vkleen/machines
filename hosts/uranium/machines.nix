{ ... }:
{
  systemd.nspawn = {
    "ubuntu" = {
      enable = false;
      execConfig = {
        Boot = true;
        Hostname = "uranium-ubuntu";
        PrivateUsers = false;
      };
      networkConfig = {
        Private = true;
        Interface = "ubuntu";
      };
    };
    "ubuntu-xplane" = {
      enable = false;
      execConfig = {
        Boot = true;
        Hostname = "uranium-xplane";
        PrivateUsers = false;
      };
      networkConfig = {
        Private = true;
        Interface = "xplane";
      };
    };
  };
  systemd.services."systemd-nspawn@ubuntu" = {
    enable = false;
    wantedBy = [ ];
    overrideStrategy = "asDropin";
    serviceConfig = {
      ProtectKernelTunables = false;
      ProtectKernelLogs = false;
      CapabilityBoundingSet = "~";
    };
  };
  systemd.services."systemd-nspawn@ubuntu-xplane" = {
    enable = false;
    wantedBy = [ ];
    overrideStrategy = "asDropin";
  };

  environment.persistence."/persist".directories = [
    "/var/lib/libvirt"
  ];
}
