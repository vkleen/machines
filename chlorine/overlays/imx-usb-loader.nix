self: super: {
  imx_usb_loader = with self; stdenv.mkDerivation {
    name = "imx_usb_loader";
    src = self.fetchFromGitHub {
      owner = "boundarydevices";
      repo = "imx_usb_loader";
      rev = "30b43d69770cd69e84c045dc9dcabb1f3e9d975a";
      hash = "sha256:1jdxbg63qascyl8x32njs9k9gzy86g209q7hc0jp74qyh0i6fwwc";
    };
    nativeBuildInputs = [ pkgconfig makeWrapper ];
    buildInputs = [ libusb1 ];

    installFlags = [ "prefix=" "DESTDIR=$(out)" ];
    preFixup = ''
      wrapProgram "$out"/bin/imx_usb --add-flags '-c "'$out'"/etc/imx-loader.d'
      wrapProgram "$out"/bin/imx_uart --add-flags '-c "'$out'"/etc/imx-loader.d'
    '';
  };
}
