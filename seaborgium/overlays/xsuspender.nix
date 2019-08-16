self: super: {
  xsuspender = super.xsuspender.overrideAttrs (_: {
    src = self.fetchFromGitHub {
      owner = "vkleen";
      repo = "xsuspender";
      rev = "9aed222e803af2f035121255936477dc5571ae2e";
      sha256 = "1ql0dgjb200nb4f0qyryhs0lv1jl8ig54n781qiaaz132bdg02f0";
    };
  });
}
