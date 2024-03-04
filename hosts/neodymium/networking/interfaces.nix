{ wolkenheim, ... }:
let
  inherit (wolkenheim.nix) mkV4 mkV6;
in
{
  system.publicAddresses = [
    (mkV4 "202.61.250.130")
    (mkV4 "188.68.45.180")
    (mkV6 "2a03:4000:54:9b1::1")
  ];
  networking = {
    useDHCP = false;
    nameservers = [
      "8.8.8.8"
      "2001:4860:4860::8888"
    ];
    defaultGateway = {
      address = "202.61.248.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    interfaces = {
      "eth0" = {
        ipv4.addresses = [
          {
            address = "202.61.250.130";
            prefixLength = 22;
          }
          {
            address = "188.68.45.180";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a03:4000:54:9b1::1";
            prefixLength = 64;
          }
          {
            address = "2a03:4000:54:9b1::25";
            prefixLength = 64;
          }
        ];
      };
    };
  };
}
