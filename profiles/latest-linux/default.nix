{ flake, pkgs, lib, pkgSources, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_testing.extend (self: super: {
    kernel = with (import "${pkgSources.local}/lib/kernel.nix" { inherit lib; });
      super.kernel.override {
        structuredExtraConfig = {
          PKCS8_PRIVATE_KEY_PARSER = yes;

          BATMAN_ADV_NC = yes;

          MAC80211_MESH = yes;

          MOUSE_PS2_ELANTECH = yes;
          MOUSE_PS2_ELANTECH_SMBUS = yes;
          MOUSE_ELAN_I2C = module;
          MOUSE_ELAN_I2C_I2C = no;
          MOUSE_ELAN_I2C_SMBUS = yes;

          POWERCAP = yes;
          IDLE_INJECT = yes;
          INTEL_RAPL = module;

          USB_CONFIGFS_F_HID = yes;
          USB_CONFIGFS_F_UVC = yes;
          USB_CONFIGFS_MASS_STORAGE = yes;
          USB_CONFIGFS_SERIAL = yes;

          USB_F_HID = module;
          USB_F_MASS_STORAGE = module;
          USB_F_SERIAL = module;
          USB_F_UVC = module;
          USB_GADGETFS = module;
          USB_GADGET_TARGET = module;

          USB_G_HID = module;

          USB_G_WEBCAM = module;
          USB_MASS_STORAGE = module;

          USB_U_SERIAL = module;
        };
      };
  });
}
