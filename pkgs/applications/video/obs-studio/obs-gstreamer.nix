# (the following is somewhat lifted from ./linuxbrowser.nix)
# We don't have a wrapper which can supply obs-studio plugins so you have to
# somewhat manually install this:

# nix-env -f . -iA obs-wlrobs
# mkdir -p ~/.config/obs-studio/plugins/wlrobs/bin/64bit
# ln -s ~/.nix-profile/share/obs/obs-plugins/wlrobs/bin/64bit/libwlrobs.so ~/.config/obs-studio/plugins/wlrobs/bin/64bit
{ stdenv, fetchFromGitHub, obs-studio
, meson, ninja, pkgconfig, lib
, gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "obs-gstreamer";
  version = "1969d5beef7fe43a68804165c8ae65dfd13035d8";

  src = fetchFromGitHub {
    owner = "fzwoch";
    repo = "obs-gstreamer";
    rev = "${version}";
    hash = "sha256-YumJXszZHqEO4259mp7oqIqUZ38aKviv06m8zYPoIzA=";
  };

  buildInputs = [ meson ninja pkgconfig obs-studio ] ++
    (with gst_all_1; [ gst-plugins-base gst-plugins-good gst-plugins-ugly gst-libav ]);

  installPhase = ''
    mkdir -p $out/share/obs/obs-plugins/obs-gstreamer/bin/64bit
    cp ./obs-gstreamer.so $out/share/obs/obs-plugins/obs-gstreamer/bin/64bit/
  '';
}
