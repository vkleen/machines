{ ... }:
{
  services.udev.extraRules = ''
    #UHK
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0660", GROUP:="input", ATTR{power/control}="on"

    #DSLogic
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0be5|0bdd", MODE:="0660", GROUP:="kvm", ATTR{power/control}="on"
  '';
}
