{ trilby, lib, ... }:
{
  age.rekey = {
    # hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8";
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlR5ZsupLXc7kKf1h8//IKdDGRMwiq8xaUTtD7L/eDf";
    forceRekeyOnSystem = trilby.buildPlatform;
    agePlugins = lib.mkForce [ ];
  };
}
