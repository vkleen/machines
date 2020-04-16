{ fetchgit, stdenv, meson, pkgconfig, json_c, scdoc, ninja, gtk-layer-shell, gtk3 }:
stdenv.mkDerivation rec {
  pname = "greetd";
  version = "git";

  src = fetchgit {
    url = "https://git.sr.ht/~kennylevinsen/gtkgreet";
    rev = "ea21a836d69953325ee26e6eac7a2b495a7fcc01";
    sha256 = "0cpglwcjc1jvjvjd0c18r17aa1xdx90kxv0v9m291x3q0p42w0dy";
  };

  mesonFlags = [ "-Dlayershell=true" ];

  nativeBuildInputs = [ meson pkgconfig ninja ];
  buildInputs = [ gtk-layer-shell gtk3 json_c scdoc ];
}
