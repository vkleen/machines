{ ... }:
{
  services.udev.extraRules = ''
    #UHK
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0660", GROUP:="input", ATTR{power/control}="on"

    #DSLogic
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a0e", ATTRS{idProduct}=="0003|0020", MODE:="0660", GROUP:="input"

    #J-Link
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101|0105", MODE:="0660", OWNER:="vkleen", GROUP:="users"
  '';
}
