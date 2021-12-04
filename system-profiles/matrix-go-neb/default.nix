{ flake, config, pkgs, ... }:
{
  age.secrets.go-neb-token.file = ../../secrets/go-neb-token.age;
  services.go-neb = {
    enable = true;
    bindAddress = "localhost:4050";
    baseUrl = "http://localhost:4050";
    secretFile = "/run/agenix/go-neb-token";
    config = {
      clients = [
        {
          "UserID" = "@go-neb:kleen.org";
          "AccessToken" = "$ACCESS_TOKEN";
          "DeviceID" = "$DEVICE_ID";
          "HomeserverURL" = "https://matrix.kleen.org";
          "Sync" = true;
          "AutoJoinRooms" = true;
          "DisplayName" = "RSS Aggregator";
        }
      ];
      services = [
        {
          "ID" = "debug_echo";
          "Type" = "echo";
          "UserID" = "@go-neb:kleen.org";
          "Config" = {};
        }
        {
          "ID" = "rss_service";
          "Type" = "rssbot";
          "UserID" = "@go-neb:kleen.org";
          "Config" = {
            "feeds" = {
              "https://lwn.net/headlines/rss" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://arxiv.org/rss/math.KT" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.CT" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.AG" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.AT" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://xkcd.com/rss.xml" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://www.questionablecontent.net/QCRSS.xml" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://www.smbc-comics.com/comic/rss" = {
                "rooms" = [ "!vGDUsKgLvtIdByzbWf:kleen.org" ];
                "poll_interval_mins" = 60;
              };
            };
          };
        }
      ];
    };
  };
}

