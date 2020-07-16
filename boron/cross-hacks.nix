{ lib, ... }:
{
  documentation.info.enable = lib.mkForce false;
  security.polkit.enable = lib.mkForce false;
}
