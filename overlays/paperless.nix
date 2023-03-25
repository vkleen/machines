final: prev: {
  paperless-ngx =
    prev.paperless-ngx.overrideAttrs (o: {
      patches = [ ./paperless-lobotomize-classifier.patch ];
      installCheckPhase = ":";
    });
}
