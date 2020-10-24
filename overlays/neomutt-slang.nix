final: prev: {
  neomutt-slang = (prev.neomutt.overrideAttrs (o: {
    configureFlags = o.configureFlags ++ [ "--with-ui=slang" ];
  })).override { ncurses = final.slang; };
}
