{ config, pkgs, ... }:
let
  akvcam_config = pkgs.writeText "config.ini" ''
    [Cameras]
    cameras/size = 2

    cameras/1/type = output
    cameras/1/mode = mmap, userptr, rw
    cameras/1/description = akvcam output
    cameras/1/formats = 2
    cameras/1/videonr = 15

    cameras/2/type = capture
    cameras/2/mode = mmap, rw
    cameras/2/description = akvcam input
    cameras/2/formats = 1, 2

    [Formats]
    formats/size = 2

    formats/1/format = RGB24, YUY2
    formats/1/width = 1280
    formats/1/height = 720
    formats/1/fps = 30

    formats/2/format = RGB24
    formats/2/width = 1280
    formats/2/height = 720
    formats/2/fps = 30

    [Connections]
    connections/size = 1
    connections/1/connection = 1:2
  '';
in {
  environment.systemPackages = [
    config.boot.kernelPackages.v4l2loopback
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  # boot.extraModprobeConfig = ''
  #   options akvcam config_file=${akvcam_config}
  # '';
}
