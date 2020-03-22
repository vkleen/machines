self: super: {
  kakoune = super.kakoune.overrideAttrs (o: {
    src = self.fetchFromGitHub {
      repo = "kakoune";
      owner = "mawww";
      rev = "a701a672bee435e47e26ae65d164a342299a657f";
      sha256 = "1rdnkmzn3bmjwz0qh3y1g836pxqcilwwyhkc01zf2spdq35vjpc4";
    };
  });
}
