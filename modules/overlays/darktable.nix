{ inputs, ... }:

final: prev: {
  libgphoto2 = prev.libgphoto2.overrideAttrs (o: {
    src = inputs.libgphoto2;
  });
}
