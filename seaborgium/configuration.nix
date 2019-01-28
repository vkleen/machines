{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./email.nix
      ./users.nix
      ./networking.nix
      ./custom/uucp.nix
      ./custom/lock-on-suspend.nix
      ./nginx.nix
      ./power.nix
      ./tor.nix
      ./cups.nix
      ./nspawn.nix
      ./fcitx.nix
      ./xserver.nix
    ];

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-overlays=${./overlays}"
    ];

    binaryCaches = [
      "https://cache.nixos.org/"
      "https://ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      "freyr.1:d8VFt+9VtvwWAMKEGEERpZtWWh8Z3bDf+O2HrOLjBYQ="
      "ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org-1:reOmDDtgU13EasMsy993sq3AuzGmXwfSxNTYPfGf3Hc="
    ];
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/nvme0n1";

  boot.kernel.sysctl = { "net.ipv4.ip_default_ttl" = 65; };

  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    kernel = with (import "${pkgs.path}/lib/kernel.nix" { inherit lib; inherit (super.kernel) version; });
      super.kernel.override {
        structuredExtraConfig = {
          PKCS8_PRIVATE_KEY_PARSER = yes;

          POWERCAP = yes;
          IDLE_INJECT = yes;
          INTEL_RAPL = module;
        };
      };
  });

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };
  networking.hostId = "b01a0a7d";
  environment.etc."machine-id".text = "b01a0a7d66dbb73b74ddde865b1c4386";

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

  # Disable bpf() JIT (to eliminate spray attacks)
  boot.kernel.sysctl."net.core.bpf_jit_enable" = false;

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
    # XXX: This breaks the intel GPU for unknown reasons
#    "intel_iommu=on"
  ];

  networking.hostName = "seaborgium";

  time.timeZone = "America/Los_Angeles";

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
    timesyncd.enable = true;

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
      babelstone-han corefonts
      noto-fonts noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      emacs-all-the-icons-fonts material-icons
      pragmatapro
      libertine xits-math
    ];
  };

  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ opencl-info vaapiIntel libva-utils ];
  };

  services.thermald = {
    enable = true;
    debug = false;
  };

  services.illum.enable = true;

  boot.cleanTmpDir = true;

  virtualisation = {
    docker.enable = false;
    libvirtd.enable = false;
    kvmgt = {
      enable = true;
      vgpus = {
        "i915-GVTg_V5_4" = {
          uuid = "7656394f-a77a-4a93-acee-01a1aba0ae60";
        };
      };
    };
  };

  programs.adb.enable = true;

  systemd.services."macchanger-wlan" = {
    wants = [ "network-pre.target" ];
    wantedBy = [ "iwd.service" ];
    before = [ "iwd.service" ];
    bindsTo = [ "sys-subsystem-net-devices-wlan.device" ];
    after = [ "sys-subsystem-net-devices-wlan.device" ];
    script = ''
      ${pkgs.iproute}/bin/ip link set dev wlan down
      ${pkgs.macchanger}/bin/macchanger -e wlan
      ${pkgs.iproute}/bin/ip link set dev wlan up
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0660", GROUP:="input"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a0e", ATTRS{idProduct}=="0003|0020", MODE:="0660", GROUP:="wireshark"

      SUBSYSTEM=="drm", ACTION=="change", ENV{HOTPLUG}=="1" RUN+="${pkgs.autorandr}/bin/autorandr --batch -c --default clone-largest"

      SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.powerscript}/bin/powerscript.sh offline"
      SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.powerscript}/bin/powerscript.sh online"
    '';

  system.nixos = rec {
    revision = lib.commitIdFromGitRepo "${toString ./../.git}";
    versionSuffix = ".git." + revision;
  };
}
