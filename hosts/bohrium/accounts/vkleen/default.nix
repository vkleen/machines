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

  home-manager.users.vkleen = lib.mkMerge (with inputs.self.nixosModules.home; [
    foot
    workstation
    neovim
  ] ++ (with (lib.findModules ./.); [
    fuzzel
    git
    gmail
    hyprland
    mpv
    neomutt
    neovim
    packages
    pass
    wireplumber
    {
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }
  ]));
}
