{ trilby, ... }:
{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEPgawj3/wTcdUHhCXUAWE69oevE+bDNvxNoSzPIeOM";
    forceRekeyOnSystem = trilby.buildPlatform;
  };
}
