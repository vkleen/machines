let
  vkleen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b";

  bohrium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEPgawj3/wTcdUHhCXUAWE69oevE+bDNvxNoSzPIeOM";
  boron = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkRtSje5rDeMMd6wZFbQ1d9XlF9nqeRf40vZ8y+x1/J";
  cerium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyb8FvtvGdZPCWreikvDNfqEYCjqjj8AWkSWGTy7MmI";
  europium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODkqoX3kRPftiOdRdpHutcIbbRGrMdkKlOpINa8AUQa";
  lanthanum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRfboIyEm9otlsGyCH/zIsiGdq1aapnpMjnYG0/2qu6";
  neodymium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8";

  praseodymium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuT1KROYFMIEW2ow9l3Ar91Ro8Es3NQo2li+lAXaBYi";
in
{
  "aws/credentials.age".publicKeys = [vkleen bohrium];
  "aws/aws-vkleen-nix-cache-1.private.age".publicKeys = [vkleen];

  "go-neb-token.age".publicKeys = [vkleen europium];

  "wireguard/bohrium.age".publicKeys = [vkleen bohrium];
  "wireguard/boron.age".publicKeys = [vkleen boron];
  "wireguard/cerium.age".publicKeys = [vkleen cerium];
  "wireguard/chlorine.age".publicKeys = [vkleen];
  "wireguard/europium.age".publicKeys = [vkleen europium];
  "wireguard/helium.age".publicKeys = [vkleen];
  "wireguard/lanthanum.age".publicKeys = [vkleen lanthanum];
  "wireguard/nitrogen.age".publicKeys = [vkleen];
  "wireguard/freerange.age".publicKeys =[vkleen boron];
  "wireguard/neodymium.age".publicKeys =[vkleen neodymium];
  "wireguard/praseodymium.age".publicKeys =[vkleen praseodymium];

  "nix/europium.1.sec.age".publicKeys = [vkleen europium];

  "mosquitto/mqtt.key.age".publicKeys = [vkleen boron];
  "mosquitto/mqtt.pem.age".publicKeys = [vkleen boron];
  "mosquitto/relayd-passwd.age".publicKeys = [vkleen boron];
  "mosquitto/root-passwd.age".publicKeys = [vkleen boron];
  "mosquitto/zigbee2mqtt-passwd.age".publicKeys = [vkleen boron];
  "mosquitto/mqtt2prom-passwd.age".publicKeys = [vkleen boron];
  "zigbee2mqtt.age".publicKeys = [vkleen boron];
  "mqtt2prom.age".publicKeys = [vkleen boron];

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
  "wolkenheim/sbag-bgp-password.age".publicKeys = [vkleen praseodymium];

  "ejabberd-config-secrets.age".publicKeys = [vkleen boron europium];
  "bifrost-registration.age".publicKeys = [vkleen boron europium];
  "heisenbridge-registration.age".publicKeys = [vkleen boron europium];

  "grafana/admin-password.age".publicKeys = [vkleen boron];
  "grafana/secret-key.age".publicKeys = [vkleen boron];

  "sourcehut/network-key.age".publicKeys = [vkleen boron];
  "sourcehut/service-key.age".publicKeys = [vkleen boron];
  "sourcehut/git-oauth-client-secret.age".publicKeys = [vkleen boron];
  "sourcehut/paste-oauth-client-secret.age".publicKeys = [vkleen boron];
  "sourcehut/webhooks-private-key.age".publicKeys = [vkleen boron];
  "sourcehut/email-key.age".publicKeys = [vkleen boron];

  "uucp/id_ed25519.age".publicKeys = [vkleen bohrium boron];

  "zte-credentials.age".publicKeys = [vkleen boron];
  "lithium-prometheus-credentials.age".publicKeys = [vkleen boron];

  "paperless/admin-pass.age".publicKeys = [vkleen boron];
  "paperless/secret-key.age".publicKeys = [vkleen boron];
  "paperless/client_cert.pem.age".publicKeys = [vkleen bohrium];

  "radicale/users.age".publicKeys = [vkleen boron];
  "radicale/client_cert.pem.age".publicKeys = [vkleen bohrium];
}
