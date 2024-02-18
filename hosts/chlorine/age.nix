{ lib, ... }:
{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmcRnGSfx23U8d/OGsBB9x0raOlRe9BhzKyfOWpIS9n";
    agePlugins = lib.mkForce [ ];
  };
}
