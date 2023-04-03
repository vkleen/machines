{ lib, ... }:
{
  types = {
    networkAddress = lib.types.submodule (_: {
      options = {
        type = lib.mkOption {
          type = lib.types.enum [ "v4" "v6" ];
          description = "Address type";
        };
        addr = lib.mkOption {
          type = lib.types.str;
          description = "Address";
        };
      };
    });
  };
}