let
  vkleen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b";

  bohrium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEPgawj3/wTcdUHhCXUAWE69oevE+bDNvxNoSzPIeOM";
  boron = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkRtSje5rDeMMd6wZFbQ1d9XlF9nqeRf40vZ8y+x1/J";
  europium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODkqoX3kRPftiOdRdpHutcIbbRGrMdkKlOpINa8AUQa";
  samarium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4wuOpHO+UmLG+D5xEQadJaeR5lm7FKmt22a2uysOYE";
  lanthanum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQlRlLUKTTjKrwzPD+djLIaWQ36aXUpPkKJcAULmey2";
  cerium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqPhc/mYvz9ZpcqXJmM/2YEnQ2WhEl3jwc11ZRKy8Jb";

  all-systems = [ bohrium boron europium samarium lanthanum cerium ];
in
{
  "aws/credentials.age".publicKeys = [vkleen bohrium];
  "aws/aws-vkleen-nix-cache-1.private.age".publicKeys = [vkleen];

  "go-neb-token.age".publicKeys = [vkleen europium];

  "wireguard/bohrium.age".publicKeys = [vkleen bohrium];
  "wireguard/boron.age".publicKeys = [vkleen boron];
  "wireguard/cerium.age".publicKeys = [vkleen lanthanum];
  "wireguard/chlorine.age".publicKeys = [vkleen];
  "wireguard/europium.age".publicKeys = [vkleen europium];
  "wireguard/helium.age".publicKeys = [vkleen];
  "wireguard/lanthanum.age".publicKeys = [vkleen lanthanum];
  "wireguard/samarium.age".publicKeys = [vkleen samarium];
  "wireguard/nitrogen.age".publicKeys = [vkleen];

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
  "coturn-auth.age".publicKeys = [ vkleen europium ];
  "synapse-coturn.age".publicKeys = [ vkleen europium ];

  "kea-boron-tsig.age".publicKeys = [vkleen boron];

  "vultr.age".publicKeys = [vkleen bohrium];

  "wolkenheim/gobgp-auth-password-lanthanum.age".publicKeys = [vkleen lanthanum];
  "wolkenheim/gobgp-auth-password-cerium.age".publicKeys = [vkleen cerium];

  "wolkenheim/vultr-bgp-password-lanthanum.age".publicKeys = [vkleen lanthanum];
  "wolkenheim/vultr-bgp-password.age".publicKeys = [vkleen lanthanum cerium];

  "ejabberd-config-secrets.age".publicKeys = [vkleen boron europium];
  "bifrost-registration.age".publicKeys = [vkleen boron europium];
}
