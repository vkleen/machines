{ flake, config, pkgs, ...}:
{
  config = {
    services.heisenbridge = {
      enable = true;
      homeserver = "https://matrix.kleen.org";
      address = "10.172.40.136";
      owner = "@viktor:kleen.org";
    };
    networking.firewall.interfaces."wg-europium".allowedTCPPorts = [ config.services.heisenbridge.port ];
    fileSystems."/var/lib/heisenbridge" = {
      device = "/persist/heisenbridge";
      options = [ "bind" ];
    };
  };
}
