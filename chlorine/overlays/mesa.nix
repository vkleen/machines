self: super: {
  mesa = (super.mesa.override {
    galliumDrivers = [ "r300" "r600" "radeonsi" "virgl" ];
    driDrivers = [ "r200" ];
    vulkanDrivers = [ "amd" ];
  }).overrideAttrs (o: {
    postFixup = ''
      # set the default search path for DRI drivers; used e.g. by X server
      substituteInPlace "$dev/lib/pkgconfig/dri.pc" --replace "$drivers" "${self.libglvnd.driverLink}"

      # remove pkgconfig files for GL/EGL; they are provided by libGL.
      rm -f $dev/lib/pkgconfig/{gl,egl}.pc

      # Update search path used by pkg-config
      for pc in $dev/lib/pkgconfig/{d3d,dri}.pc; do
        substituteInPlace "$pc" --replace $out $drivers
      done

      # add RPATH so the drivers can find the moved libgallium and libdricore9
      # moved here to avoid problems with stripping patchelfed files
      for lib in $drivers/lib/*.so* $drivers/lib/*/*.so*; do
        if [[ ! -L "$lib" ]]; then
          patchelf --set-rpath "$(patchelf --print-rpath $lib):$drivers/lib" "$lib"
        fi
      done
    '';
  });
}
