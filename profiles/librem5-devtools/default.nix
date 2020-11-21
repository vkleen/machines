{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.uuu
  ];

  services.udev.extraRules = ''
    SUBSYSTEM!="usb", GOTO="librem5_devkit_rules_end"
    # Devkit USB flash
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="012b", GROUP+="dialout", TAG+="uaccess"
    ATTR{idVendor}=="0525", ATTR{idProduct}=="a4a5", GROUP+="dialout", TAG+="uaccess"
    ATTR{idVendor}=="0525", ATTR{idProduct}=="b4a4", GROUP+="dialout", TAG+="uaccess"
    LABEL="librem5_devkit_rules_end"
    EOF
  '';
}
