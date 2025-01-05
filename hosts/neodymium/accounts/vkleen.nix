{ lib, config, ... }:
{
  users.users.vkleen = {
    extraGroups = [
      "network" "xmpp"
    ];
    # hashedPasswordFile = lib.mkForce config.age.secrets."vkleen-neodymium-pass".path;
  };
  #
  # age.secrets."vkleen-neodymium-pass" = {
  #   rekeyFile = ../../../secrets/vkleen-neodymium-pass.age;
  #   owner = "root";
  # };
}
