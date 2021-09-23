{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      services.bitlbee = {
        enable = true;
        authBackend = "pam";
        libpurple_plugins = [
          pkgs.purple-lurch
          pkgs.pidgin-carbons
          pkgs.pidgin-xmpp-receipts
          pkgs.purple-plugins-prpl
        ];
      };

      users.users.bitlbee.group = "bitlbee";
      users.groups.bitlbee = {};
    }
    (lib.mkIf config.boot.wipeRoot {
      fileSystems."/var/lib/bitlbee" = {
        device = "/persist/bitlbee";
        options = [ "bind" ];
      };
    })
  ]);

}
