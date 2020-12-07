{ runCommand, stdenv, fetchurl, appimage-run }:
let
  version = "1.5.8";

  image = stdenv.mkDerivation {
    name = "uhk-agent-image";
    src = fetchurl {
      url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
      hash = "sha256-8VPTw/gNlsl+QneKxlotsYH3wGSPPpepEkRVbitrJI0=";
    };
    buildCommand = ''
      mkdir -p $out
      cp $src $out/appimage
      chmod ugo+rx $out/appimage
    '';
  };

  appimage-run' = appimage-run.override {
    extraPkgs = p: with p; [
      at-spi2-core
    ];
  };

in runCommand "uhk-agent" {} ''
    mkdir -p $out/bin $out/etc/udev/rules.d
    echo "${appimage-run'}/bin/appimage-run ${image}/appimage" > $out/bin/uhk-agent
    chmod +x $out/bin/uhk-agent
    cat > $out/etc/udev/rules.d/50-uhk60.rules <<EOF
    # Ultimate Hacking Keyboard rules
    # These are the udev rules for accessing the USB interfaces of the UHK as non-root users.
    # Copy this file to /etc/udev/rules.d and physically reconnect the UHK afterwards.
    SUBSYSTEM=="input", GROUP="input", MODE="0664"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0664", GROUP="plugdev"
    EOF
  ''
