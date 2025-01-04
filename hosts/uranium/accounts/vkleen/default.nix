{ lib, inputs, ... }:
{
  users.users.vkleen = {
    extraGroups = [
      "adbusers"
      "audio"
      "bladerf"
      "camera"
      "dialout"
      "docker"
      "input"
      "jackaudio"
      "kvm"
      "libvirtd"
      "lp"
      "network"
      "scanner"
      "uinput"
      "video"
      "wireshark"
    ];

    openssh.authorizedKeys.keys = [
      "command=\"/run/current-system/sw/bin/nix-daemon --stdio\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHphiGeRW2Q+kMci0sjWbGxI1dzVPp3LZ7npWMMzgUiX"
    ];
  };

  home-manager.users.vkleen = lib.mkMerge (with inputs.self.nixosModules.home; [
    foot
    workstation
  ]
  ++ (lib.findModulesList ./.)
  ++ [
    {
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }
  ]);
}
