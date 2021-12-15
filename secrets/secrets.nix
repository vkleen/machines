let
  vkleen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b";

  bohrium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEPgawj3/wTcdUHhCXUAWE69oevE+bDNvxNoSzPIeOM";
  boron = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkRtSje5rDeMMd6wZFbQ1d9XlF9nqeRf40vZ8y+x1/J";
  europium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODkqoX3kRPftiOdRdpHutcIbbRGrMdkKlOpINa8AUQa";
  samarium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4wuOpHO+UmLG+D5xEQadJaeR5lm7FKmt22a2uysOYE";
  gadolinium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJjXDWb3CZ1Ff9PfyWt7wtsYxwm5vkpEOrVBgxLKfeh";

  all-systems = [ bohrium boron europium samarium gadolinium ];
in
{
  "aws/credentials.age".publicKeys = [vkleen bohrium];
  "aws/aws-vkleen-nix-cache-1.private.age".publicKeys = [vkleen];

  "go-neb-token.age".publicKeys = [vkleen europium];

  "wireguard/bohrium.age".publicKeys = [vkleen bohrium];
  "wireguard/boron.age".publicKeys = [vkleen boron];
  "wireguard/chlorine.age".publicKeys = [vkleen];
  "wireguard/europium.age".publicKeys = [vkleen europium];
  "wireguard/helium.age".publicKeys = [vkleen];
  "wireguard/samarium.age".publicKeys = [vkleen samarium];
  "wireguard/gadolinium.age".publicKeys = [vkleen gadolinium];

  "nix/europium.1.sec.age".publicKeys = [vkleen europium];
  "nix/samarium.2.sec.age".publicKeys = [vkleen samarium];

  "mosquitto/mqtt.key.age".publicKeys = [vkleen boron];
  "mosquitto/mqtt.pem.age".publicKeys = [vkleen boron];

  "rmfakecloud/jwtKey.age".publicKeys = [vkleen boron];
  "rmfakecloud/hwrAppKey.age".publicKeys = [vkleen boron];
  "rmfakecloud/hwrHMAC.age".publicKeys = [vkleen boron];
  "rmfakecloud/rmapi.age".publicKeys = [vkleen bohrium];

  "dptrp1.age".publicKeys = [vkleen bohrium];
  "dptrp1.key.age".publicKeys = [vkleen bohrium];

  "rsync.age".publicKeys = [vkleen bohrium boron];
  "boron-borg.age".publicKeys = [vkleen boron];

  "synapse-registration.age".publicKeys = [ vkleen europium ];

  "kea-boron-tsig.age".publicKeys = [vkleen boron];
}
