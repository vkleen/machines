self: super: {
  greetd = self.callPackage ./wayland/greetd.nix {};
  gtkgreet = self.callPackage ./wayland/gtkgreet.nix {};
}
