{ lib, ... }:
{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyYQbhWyCLsM3V15HKrOattPaI0zbntG3onx+UtYHQx";
    agePlugins = lib.mkForce [ ];
  };
}
