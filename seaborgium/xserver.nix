{config, pkgs, lib, ...}:
with lib; let
  cfg = config.services.xserver;
in {
  services.xserver = {
    enable = true;
    autorun = true;
    xkbOptions = "compose:ralt";
    serverFlagsSection = ''
      Option "BlankTime" "5"
      Option "StandbyTime" "10"
      Option "SuspendTime" "15"
      Option "OffTime" "20"
    '';
    useGlamor = true;
    displayManager = {
      slim.enable = true;
      session = lib.mkForce [];
    };
    windowManager.i3 = {
      enable = true;
    };
    libinput = {
      enable = true;
      naturalScrolling = true;
      accelSpeed = "0.7";
    };
    inputClassSections = [
      ''
        Identifier "USB Trackpoint"
          MatchProduct "Lenovo ThinkPad Compact USB Keyboard with TrackPoint"
          MatchIsPointer "1"
          Option "AccelProfile" "flat"
          Option "TransformationMatrix" "6 0 0 0 6 0 0 0 1"
          Option "NaturalScrolling" "1"
      ''
      ''
        Identifier "USB Trackpoint"
          MatchProduct "ThinkPad Compact Bluetooth Keyboard with TrackPoint"
          MatchIsPointer "1"
          Option "AccelProfile" "flat"
          Option "TransformationMatrix" "6 0 0 0 6 0 0 0 1"
          Option "NaturalScrolling" "1"
        ''
    ];
  };

  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  environment.systemPackages = with pkgs; [ brillo ];
  services.udev.packages = with pkgs; [ brillo ];
}
