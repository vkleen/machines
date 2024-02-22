{ lib, config, ... }:
let
  cfg = config.wolkenheim.wireguard;
in
{
  options = {
    wolkenheim.wireguard = {
      enable = lib.mkEnableOption "wolkenheim wireguard";
      public = lib.mkOption {
        type = lib.types.singleLineStr;
      };
      private = lib.mkOption {
        type = lib.types.path;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    age.secrets."wolkenheim-wireguard".rekeyFile = cfg.private;
  };
}
