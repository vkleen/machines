{ nixosConfig, inputs, ... }:
{
  imports = with inputs.self.nixosModules.home; [
    mpv
  ];
  config = {
    mpv.ipc-socket = "/run/user/${builtins.toString nixosConfig.users.users.vkleen.uid}/mpv";
  };
}
