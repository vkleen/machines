{ trilby, inputs, config, lib, ... }:

{
  imports = [
    inputs.trilby.inputs.home-manager.nixosModules.home-manager
  ];

  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs trilby;
      lib = lib // inputs.trilby.inputs.home-manager.lib;
      nixosConfig = config;
    };
  };
}
