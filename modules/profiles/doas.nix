{ lib, ... }:
{
  security.doas = {
    enable = true;
    extraRules = lib.mkForce [
      {
        groups = [ "wheel" ];
        keepEnv = true;
        noPass = false;
        persist = true;
      }
    ];
  };

  security.sudo.enable = false;
}