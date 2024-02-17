{ ... }:
final: prev: {
  pipewire = prev.pipewire.override { ffadoSupport = false; };
}
