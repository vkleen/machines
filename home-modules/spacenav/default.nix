{config, nixos, pkgs, lib, ...}:
let
  socket = "/run/user/${builtins.toString nixos.users.users.vkleen.uid}/spacenavd.sock";
  configFile = pkgs.writeText "spnavrc" ''
    # Sensitivity is multiplied with every motion (1.0 normal).
    #sensitivity = 1.0


    # Separate sensitivity for rotation and translation.
    #sensitivity-translation = 1.0
    #sensitivity-rotation = 1.0


    # Dead zone; any motion less than this number is discarded as noise.
    #dead-zone = 2


    # Selectively invert translation and rotation axes. Valid values are
    # combinations of the letters x, y, and z.
    #invert-rot = yz
    #invert-trans = yz


    # Swap Y and Z axes
    #swap-yz = false


    # Serial device
    # Set this only if you have a serial device, and make sure you specify the
    # correct device file. If you do set this option, any USB devices will be
    # ignored!
    #serial = /dev/ttyS0


    # Enable/disable LED light (for devices that have one).
    led = off

    sock_name = ${socket}
    pidfile = /run/user/${builtins.toString nixos.users.users.vkleen.uid}/spacenavd.pid
  '';
in {
  home.sessionVariables = {
    SPNAV_SOCKET = "${socket}";
  };

  systemd.user.services.spacenavd = {
    Unit = {
      Description = "Spacenavd";
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.spacenavd}/bin/spacenavd -d -l syslog -c ${configFile}";
    };
  };
}
