{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    profiles.uucp-email
  ];
  config = {
    uucp-email = {
      secretFile = ../../secrets/uucp/bohrium.age;
      upstream.name = "neodymium";
      upstream.host = "10.172.50.1"; # "202.61.250.130";
      upstream.sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8";
    };
  };
}

