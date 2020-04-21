{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./cups.nix
      ./custom/lock-on-suspend.nix
      ./custom/uucp.nix
      ./dconf.nix
      ./email.nix
      ./hardware-configuration.nix
      ./networking.nix
      ./nginx.nix
      ./nspawn.nix
      ./power.nix
      ./users.nix
      ./wayland.nix
      # ./xserver.nix
    ];

  nix = {
    nixPath = let overlays = pkgs.writeText "overlays.nix" ''
      let
        pkgs-path = <nixpkgs>;
        lib = import "''${pkgs-path}/lib";

        all-overlays-in = dir: with builtins; with lib;
          let allNixFilesIn = dir: mapAttrs (name: _: import (dir + "/''${name}"))
                                            (filterAttrs (name: _: hasSuffix ".nix" name)
                                            (readDir dir));
          in attrValues (allNixFilesIn dir);
      in all-overlays-in ${./overlays}
    '';
    in [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-overlays=${overlays}"
    ];

    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (import ../chlorine/chlorine.1)
      (import ../cache-keys/aws-vkleen-nix-cache-1.public)
    ];

    extraOptions = ''
      secret-key-files = /private/bohrium.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  boot.binfmt.emulatedSystems = [
    "powerpc64le-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    kernel = with (import "${pkgs.path}/lib/kernel.nix" { inherit lib; });
      super.kernel.override {
        structuredExtraConfig = {
          PKCS8_PRIVATE_KEY_PARSER = yes;

          BATMAN_ADV_NC = yes;

          MAC80211_MESH = yes;

          BPFILTER = yes;
          BPFILTER_UMH = module;

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

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };

  networking.hostId = "2469eead";
  environment.etc."machine-id".text = "2469eead8c84bfe7caf902d7f00a1a7c";

  environment.etc."systemd/sleep.conf".text = lib.mkForce ''
    [Sleep]
    HibernateDelaySec=15min
  '';

  security.hideProcessInformation = false;
  security.apparmor.enable = false;

  # Restrict ptrace() usage to processes with a pre-defined relationship
  # (e.g., parent/child)
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;

  # Hide kptrs even for processes with CAP_SYSLOG
  boot.kernel.sysctl."kernel.kptr_restrict" = lib.mkOverride 500 2;

  # Unprivileged access to bpf() has been used for privilege escalation in
  # the past
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = true;

  # ... or at least apply some hardening to it
  boot.kernel.sysctl."net.core.bpf_jit_harden" = true;

  # Raise ASLR entropy for 64bit & 32bit, respectively.
  #
  # Note: mmap_rnd_compat_bits may not exist on 64bit.
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 32;
  boot.kernel.sysctl."vm.mmap_rnd_compat_bits" = 16;

  # Allowing users to mmap() memory starting at virtual address 0 can turn a
  # NULL dereference bug in the kernel into code execution with elevated
  # privilege.  Mitigate by enforcing a minimum base addr beyond the NULL memory
  # space.  This breaks applications that require mapping the 0 page, such as
  # dosemu or running 16bit applications under wine.  It also breaks older
  # versions of qemu.
  #
  # The value is taken from the KSPP recommendations (Debian uses 4096).
  boot.kernel.sysctl."vm.mmap_min_addr" = 65536;

  boot.kernelParams = lib.mkForce [
    # Overwrite free'd memory
    "page_poison=1"

    # Disable legacy virtual syscalls
    "vsyscall=none"

    "i915.enable_gvt=1" "kvm.ignore_msrs=1"
    "intel_iommu=on"
  ];

  networking.hostName = "bohrium";

  time.timeZone = "UTC";

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    logind = {
      lidSwitch = "lock";
      extraConfig = ''
        HandlePowerKey = ignore
        HandleHibernateKey = ignore
        HandleSuspendKey = ignore
        LidSwitchIgnoreInhibited = no
      '';
    };

    ntp.enable = false;
    chrony = {
      enable = true;
      initstepslew = {
        enabled = true;
        threshold = 1000;
      };
    };

    upower.enable = true;
  };

  security.sudo.configFile = ''
    Defaults:root,%wheel env_keep+=TERMINFO_DIRS
    Defaults:root,%wheel env_keep+=TERMINFO
    Defaults env_keep+=SSH_AUTH_SOCK
    Defaults !lecture,insults,rootpw

    root        ALL=(ALL) SETENV: ALL
    %wheel      ALL=(ALL:ALL) SETENV: ALL
  '';

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units") {
            if (action.lookup("unit") == "physlock.service") {
                var verb = action.lookup("verb");
                if (verb == "start") {
                    return polkit.Result.YES;
                }
            }
        }
    });
  '';

  programs.firejail.enable = true;

  environment.systemPackages = with pkgs; [
    wget vim git rsync
    adbfs-rootless
    s-tar mbuffer
    uhk-agent
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      inconsolata terminus_font ubuntu_font_family lmodern dejavu_fonts
      source-code-pro source-sans-pro source-serif-pro
      source-han-serif-simplified-chinese source-han-serif-traditional-chinese
      source-han-sans-simplified-chinese source-han-sans-simplified-chinese
      corefonts
      noto-fonts noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      emacs-all-the-icons-fonts material-icons
      pragmatapro
      libertine #xits-math
    ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  hardware.opengl = {
    enable = true;
  };

  services.thermald = {
    enable = true;
    debug = false;
  };

  boot.cleanTmpDir = true;

  virtualisation = {
    docker.enable = false;
    libvirtd = {
      enable = false;
      qemuVerbatimConfig = ''
        namespaces = []
        user = "vkleen"
        group = "libvirtd"
      '';
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    kvmgt = {
      enable = false;
      vgpus = {
        "i915-GVTg_V5_4" = {
          uuid = "7656394f-a77a-4a93-acee-01a1aba0ae60";
        };
      };
    };
  };

  programs.adb.enable = true;

  services.udev.extraRules = ''
      #UHK
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0660", GROUP:="input", ATTR{power/control}="on"

      #DSLogic
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0be5|0bdd", MODE:="0660", GROUP:="kvm", ATTR{power/control}="on"

      #DPT
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a0e", ATTRS{idProduct}=="0003|0020", MODE:="0660", GROUP:="wireshark"

      SUBSYSTEM!="usb", GOTO="librem5_devkit_rules_end"
      # Devkit USB flash
      ATTR{idVendor}=="1fc9", ATTR{idProduct}=="012b", GROUP:="dialout", MODE:="0660"
      ATTR{idVendor}=="0525", ATTR{idProduct}=="a4a5", GROUP:="dialout", MODE:="0660"
      ATTR{idVendor}=="0525", ATTR{idProduct}=="b4a4", GROUP:="dialout", MODE:="0660"
      LABEL="librem5_devkit_rules_end"

      # SUBSYSTEM=="drm", ACTION=="change", ENV{HOTPLUG}=="1" RUN+="${pkgs.autorandr}/bin/autorandr --batch -c --default clone-largest"

      SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    '';

  security.wrappers = {
    fping = {
      source = "${pkgs.fping}/bin/fping";
      owner = "nobody";
      group = "nogroup";
      capabilities = "cap_net_raw+ep";
    };
  };

  system.stateVersion = "20.03";
}
