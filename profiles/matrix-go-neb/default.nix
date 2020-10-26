flake:
{config, pkgs, ...}:
let
  go-neb-token = import ../../secrets/go-neb-token.nix;
in {
  services.go-neb = {
    enable = true;
    bindAddress = "localhost:4050";
    baseUrl = "http://localhost:4050";
    config = {
      clients = [
        {
          "UserID" = "@go-neb-rss:kleen.org";
          "AccessToken" = go-neb-token;
          "HomeserverURL" = "https://matrix.kleen.org";
          "Sync" = true;
          "AutoJoinRooms" = true;
          "DisplayName" = "RSS Aggregator";
        }
      ];
      services = [
        {
          "ID" = "rss_service";
          "Type" = "rssbot";
          "UserID" = "@go-neb-rss:kleen.org";
          "Config" = {
            "feeds" = {
              "https://lwn.net/headlines/rss" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://arxiv.org/rss/math.KT" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.CT" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.AG" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://arxiv.org/rss/math.AT" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60*24;
              };
              "https://xkcd.com/rss.xml" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://www.questionablecontent.net/QCRSS.xml" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60;
              };
              "https://www.smbc-comics.com/comic/rss" = {
                "rooms" = [ "!WvhufqOWJSZzceIhKH:kleen.org" ];
                "poll_interval_mins" = 60;
              };
            };
          };
        }
      ];
    };
  };
}

