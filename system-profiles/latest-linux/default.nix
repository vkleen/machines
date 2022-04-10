{ flake, flakeInputs, config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_17;
}
