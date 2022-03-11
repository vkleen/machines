{
  AS = {
    "auenheim" = {
      announcePublic = true;
      public4 = "45.77.54.162/32";
      public6 = "2001:19f0:6c01:2bc5::/64";
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
    "samarium" = { AS = "netcup"; };
  };

  wg-links = {
    "boron" = {
      "dsl" = [
        { to = "lanthanum"; }
        { to = "cerium"; }
        { to = "samarium"; }
      ];
      "lte" = [
        { to = "lanthanum"; bfdInterval = 5000; }
        { to = "cerium"; bfdInterval = 5000; }
        { to = "samarium"; bfdInterval = 5000; }
      ];
    };

#    "nitrogen" = {
#      "dsl" = [
#        { to = "lanthanum"; }
#        { to = "cerium"; }
#        { to = "samarium"; }
#      ];
#      "lte" = [
#        { to = "lanthanum"; }
#        { to = "cerium"; }
#        { to = "samarium"; }
#      ];
#    };
  };

  uplinks = let
    vultr-uplink = {
      type = "bgp";
      credentials = ../../secrets/wolkenheim/vultr-bgp-password.age;
      remote-as = 64515;
      local-as = 4288000175;
      password = "$VULTR_BGP_PASSWORD";
      allowed-prefixes4 = [ ];
      allowed-prefixes6 = [ "2001:19f0:6c01:2bc5::/64" ];
      peer4 = "169.254.169.254";
      peer6 = "2001:19f0:ffff::1";
      extraGobgpNeighborConfig = {
        ebgp-multihop.config = {
          enabled = true;
          multihop-ttl = 2;
        };
      };
    };
  in {
    "lanthanum" = vultr-uplink;
    "cerium" = vultr-uplink;
    "samarium" = {
      type = "nat";
    };
  };

  ip4NamespaceAllocation = {
    "reserved_router_id" = 0;
    "reserved_vultr" = 169;
  };
}
