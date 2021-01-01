{ config, pkgs, ... }:
let
  wrapped-obs = pkgs.obs-studio.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [
      pkgs.makeWrapper
    ] ++ (with pkgs.gst_all_1;[
      gstreamer gst-vaapi gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
    ]);
    postInstall = ''
      wrapProgram $out/bin/obs --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
    '';
  });
in {
  home.packages = [
    wrapped-obs pkgs.obs-cli
  ];
  xdg.configFile."obs-studio/plugins/v4l2sink".source = "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink";
  xdg.configFile."obs-studio/plugins/wlrobs".source = "${pkgs.obs-wlrobs}/share/obs/obs-plugins/wlrobs";
  xdg.configFile."obs-studio/plugins/obs-gstreamer".source = "${pkgs.obs-gstreamer}/share/obs/obs-plugins/obs-gstreamer";
  xdg.configFile."obs-studio/plugins/obs-websocket".source = "${pkgs.obs-websocket}/share/obs/obs-plugins/obs-websocket";
}
