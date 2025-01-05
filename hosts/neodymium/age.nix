{ lib, ... }:
{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8";
    agePlugins = lib.mkForce [ ];
  };
}
