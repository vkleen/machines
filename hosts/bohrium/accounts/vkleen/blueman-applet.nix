{ lib, pkgs, ... }:
{
  assertions = [
    (lib.hm.assertions.assertPlatform "services.blueman-applet" pkgs
      lib.platforms.linux)
  ];

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman applet";
      PartOf = [ "hyprland-session.target" ];
    };

    Install = { WantedBy = [ "hyprland-session.target" ]; };

    Service = { ExecStart = lib.getExe' pkgs.blueman "blueman-applet"; };
  };
}
