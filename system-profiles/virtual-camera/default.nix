{ config, pkgs, ... }:
 {
  environment.systemPackages = [
    config.boot.kernelPackages.v4l2loopback
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
}
