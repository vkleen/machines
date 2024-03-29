{ config, ... }:
{
  services.rmfakecloud = {
    enable = true;
    storageUrl = "https://remarkable.kleen.org";
    jwtKey = "/run/agenix/rmfakecloud/jwtKey";
    hwrAppKey = "/run/agenix/rmfakecloud/hwrAppKey";
    hwrHMAC = "/run/agenix/rmfakecloud/hwrHMAC";
    dataDir = "/srv/rmfakecloud";
  };
  age.secrets."rmfakecloud/jwtKey" = {
    file = ../../secrets/rmfakecloud/jwtKey.age;
    owner = "root";
  };
  age.secrets."rmfakecloud/hwrAppKey" = {
    file = ../../secrets/rmfakecloud/hwrAppKey.age;
    owner = "root";
  };
  age.secrets."rmfakecloud/hwrHMAC" = {
    file = ../../secrets/rmfakecloud/hwrHMAC.age;
    owner = "root";
  };
}
