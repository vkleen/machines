{ config, pkgs, lib, ... }:
let
  inherit (builtins) substring;
  inherit (import ../../utils/ints.nix { inherit lib; }) hexToInt;
  machine_id = config.environment.etc."machine-id".text;

  private_address = let
    chars12 = substring 0 2 machine_id;
    chars34 = substring 2 2 machine_id;

    octet1 = hexToInt chars12;
    octet2 = hexToInt chars34;
  in "10.32.${builtins.toString octet1}.${builtins.toString octet2}";

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
        ipv4.addresses = [ {
          address = private_address;
          prefixLength = 16;
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
