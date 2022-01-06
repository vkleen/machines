{ config, pkgs, ... }:
let
  inherit (builtins) substring;
  machine_id = config.environment.etc."machine-id".text;
  ula_host = "${substring 0 4 machine_id}:${substring 4 4 machine_id}:${substring 8 4 machine_id}:${substring 12 4 machine_id}:${substring 16 4 machine_id}";
in {
  networking = {
    useDHCP = false;
    useNetworkd = true;
    nameservers = [
      "2001:19f0:300:1704::6"
    ];
    interfaces = {
      "enp1s0" = {
        useDHCP = true;
      };
      "enp6s0" = {
        ipv6.addresses = [ {
          address = "fd5d:9dff:9eb6:${ula_host}";
          prefixLength = 48;
        } ];
        mtu = 1450;
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
      allowPing = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
  systemd.network = {
    networks."40-enp6s0" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
  };
}
