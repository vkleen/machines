{ lib, inputs, ... }:
{
  users.users.vkleen = {
    extraGroups = [
      #lib.filter (g: config.users.groups ? g) [
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

  home-manager.users.vkleen = lib.mkMerge
    (with inputs.self.nixosModules.home; [
      alacritty
      kitty
      workstation
      neovim
    ]
    ++ lib.findModulesList ./.
    ++ [{
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }]);
}
