{pkgs, lib, config, flake, ...}:
{
  imports = [ flake.inputs.agenix.nixosModules.age ];
}
