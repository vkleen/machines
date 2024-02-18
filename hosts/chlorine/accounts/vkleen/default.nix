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
      "video"
      "wireshark"
    ];
  };

  home-manager.users.vkleen = lib.mkMerge (with inputs.self.nixosModules.home; [
    foot
    workstation
    neovim
  ] ++ (with (lib.findModules ./.); [
    neovim
    packages
    {
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }
  ]));
}
