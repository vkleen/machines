{
  AS = {
    "auenheim" = {
      announcePublic = true;
      public = "45.77.54.162/32";
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
        { to = "lanthanum"; }
        { to = "cerium"; }
        { to = "samarium"; }
      ];
    };

    "nitrogen" = {
      "dsl" = [
        { to = "lanthanum"; }
        { to = "cerium"; }
        { to = "samarium"; }
      ];
      "lte" = [
        { to = "lanthanum"; }
        { to = "cerium"; }
        { to = "samarium"; }
      ];
    };
  };

  ip4NamespaceAllocation = {
    "reserved_auenheim" = 172;
    "reserved_wolkenheim" = 32;
    "reserved_router_id" = 0;
  };
}
