{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.uuu
  ];

  services.udev.extraRules = ''
    SUBSYSTEM!="usb", GOTO="librem5_devkit_rules_end"
    # Librem5 USB flash
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="012b", GROUP="wheel", TAG+="uaccess"
    ATTR{idVendor}=="0525", ATTR{idProduct}=="a4a5", GROUP="wheel", TAG+="uaccess"
    ATTR{idVendor}=="0525", ATTR{idProduct}=="b4a4", GROUP="wheel", TAG+="uaccess"
    ATTR{idVendor}=="316d", ATTR{idProduct}=="4c05", GROUP="wheel", TAG+="uaccess"
    LABEL="librem5_devkit_rules_end"
  '';
}
