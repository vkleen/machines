self: super: {
  # inherit (self.callPackages ./radare2/radare2.nix {
  #   inherit (self.gnome2) vte;
  #   lua = self.lua5;
  #   useX11 = true;
  #   pythonBindings = true;
  #   rubyBindings = false;
  #   luaBindings = false;
  # }) radare2 r2-for-cutter;
}
