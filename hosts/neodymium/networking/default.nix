{ lib, ... }:
{
  imports = lib.findModulesList ./.;

  config = {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 2;
    };
  };
}
