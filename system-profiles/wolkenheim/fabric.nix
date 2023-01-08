{
  AS = {
    "auenheim" = {
      announcePublic = true;
      public6 = "2a06:e881:9008::/48";
    };
    "wolkenheim" = {
    };
    "netcup" = {
    };
  };

  hosts = {
    "boron" = { AS = "auenheim"; };
    "nitrogen" = { AS = "auenheim"; };
    "cerium" = { AS = "wolkenheim"; };
    "lanthanum" = { AS = "wolkenheim"; };
    "praseodymium" = { AS = "wolkenheim"; };
  };

  wg-links = {
    "boron" = {
      "dsl" = [
        { to = "lanthanum"; bfdInterval = 200; bfdDetectionMultiplier = 4; }
        { to = "cerium"; bfdInterval = 200; bfdDetectionMultiplier = 4; }
        { to = "praseodymium"; bfdInterval = 200; bfdDetectionMultiplier = 4; }
      ];
      "lte" = [
        { to = "lanthanum"; bfdInterval = 5000; }
        { to = "cerium"; bfdInterval = 5000; }
        { to = "praseodymium"; bfdInterval = 5000; }
      ];
    };
  };

  uplinks = let
    vultr-uplink = {
      type = "bgp";
      credentials = ../../secrets/wolkenheim/vultr-bgp-password.age;
      remote-as = 64515;
      local-as = 210286;
      password = "$VULTR_BGP_PASSWORD";
      allowed-prefixes4 = [ ];
      allowed-prefixes6 = [ "2a06:e881:9008::/48" ];
      peer6 = "2001:19f0:ffff::1";
      extraGobgpNeighborConfig = {
        ebgp-multihop.config = {
          enabled = true;
          multihop-ttl = 2;
        };
      };
    };

    sbag-uplink = {
      type = "bgp";
      credentials = ../../secrets/wolkenheim/sbag-bgp-password.age;
      remote-as = 58057;
      local-as = 210286;
      password = "$SBAG_BGP_PASSWORD";
      allowed-prefixes4 = [ ];
      allowed-prefixes6 = [ "2a06:e881:9008::/48" ];
      peer6 = "2a09:4c0:303:c232::5cfa";
      extraGobgpNeighborConfig = {};
    };
  in {
    "lanthanum" = vultr-uplink;
    "cerium" = vultr-uplink;
    "praseodymium" = sbag-uplink;
  };

  ip4NamespaceAllocation = {
    "reserved_router_id" = 0;
    "reserved_vultr" = 169;
  };
}
