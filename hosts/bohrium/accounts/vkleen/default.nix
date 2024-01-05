{ config, lib, inputs, ... }:
{
  users.users.vkleen = {
    extraGroups = [
      #lib.filter (g: config.users.groups ? g) [
      "network"
      "dialout"
      "audio"
      "video"
      "input"
      "wireshark"
      "adbusers"
      "bladerf"
      "kvm"
      "libvirtd"
      "lp"
      "scanner"
      "jackaudio"
      "docker"
    ];
  };

  home-manager.users.vkleen = lib.mkMerge (with inputs.self.nixosModules.home; [
    foot
    workstation
  ] ++ (with (lib.findModules ./.); [
    blueman-applet
    fuzzel
    git
    gmail
    hyprland
    mpv
    neomutt
    packages
    pass
    wireplumber
    {
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }
  ]));
}
