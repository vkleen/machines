{config, pkgs, ...}:
{
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ table table-others uniemoji ];
  };
  systemd.user.services.ibus-daemon = let
    ibusPackage = pkgs.ibus-with-plugins.override { plugins = config.i18n.inputMethod.ibus.engines; };
  in {
    enable = true;
    wantedBy = [
      "multi-user.target"
      "graphical-session.target"
    ];
    description = "IBus daemon";
    script = "${ibusPackage}/bin/ibus-daemon --xim";
    serviceConfig = {
      Restart = "always";
      StandardOutput = "syslog";
    };
  };
}
