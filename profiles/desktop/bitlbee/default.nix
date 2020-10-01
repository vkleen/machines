{ pkgs, ... }:
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
}
