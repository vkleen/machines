{ config, pkgs, ... }:
let
  vendor-reset = config.boot.kernelPackages.vendor-reset.overrideAttrs (o: {
    version = "unstable-2024-04-16";
    src = pkgs.fetchFromGitHub {
      owner = "gnif";
      repo = "vendor-reset";
      rev = "084881c6e9e11bdadaf05798e669568848e698a3";
      hash = "sha256-Klu2uysbF5tH7SqVl815DwR7W+Vx6PyVDDLwoMZiqBI=";
    };

    patches = [ ./0001-asm-unaligned.h-linux-unaligned.h.patch ];
  });

  gpu-bind = pkgs.writeShellScript "gpu-bind" ''
    if [[ -z "$DEVPATH" ]]; then
      echo "Error: No DEVPATH"
      exit 1
    fi
    _devpath=$DEVPATH
    _dbdf=''${_devpath##*/}
    _dpath=/sys$_devpath/driver

    if [[ -d $_dpath ]]; then
      _curr_driver=$(readlink $_dpath)
      _curr_driver=''${_curr_driver##*/}

      if [[ "$_curr_driver" == "vfio-pci" ]]; then
        continue
      else
        echo $dbdf > $_dpath/unbind
      fi
    fi

    echo device_specific > /sys$_devpath/reset_method
    echo 14 > /sys$_devpath/resource0_resize
    echo 3 > /sys$_devpath/resource2_resize

    echo vfio-pci > /sys$_devpath/driver_override
    echo $_dbdf > /sys/bus/pci/drivers_probe
  '';
in
{
  config = {
    boot.initrd.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" "vendor_reset" ];
    boot.blacklistedKernelModules = [ "amdgpu" ];
    boot.kernelPatches = [
      {
        name = "encrypted_key";
        patch = null;
        extraConfig = ''
          ENCRYPTED_KEYS y
        '';
      }
    ];
    boot.extraModulePackages = [ vendor-reset ];
    boot.kernelParams = [ "console=ttyS0" "intel_iommu=on" "iommu=pt" "initcall_blacklist=sysfb_init" "boot.shell_on_fail" "kvm.ignore_msrs=1" "kvm.report_ignored_msrs=0" "video=efifb:off" "vfio-pci.disable_idle_d3=1" ];
    boot.loader.grub.enable = false;


    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x6863", RUN+="${gpu-bind}"
    '';
  };
}
