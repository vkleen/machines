{ pkgs, ... }:
let
  vultr-wrapped = pkgs.writeShellScriptBin "vultr" ''
    VULTR_API_KEY=$(cat /run/agenix/vultr) ${pkgs.vultr}/bin/vultr "$@"
  '';
in {
  age.secrets."vultr" = {
    file = ../../../secrets/vultr.age;
    owner = "vkleen";
  };

  environment.systemPackages = [
    vultr-wrapped
  ];
}
