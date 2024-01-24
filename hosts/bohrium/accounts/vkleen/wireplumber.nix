{ pkgs, ... }:
# let
#   json = pkgs.formats.json { };
#   mapToFiles = service: location: config: lib.concatMapAttrs
#     (name: value: {
#       "${location}/${name}" = {
#         source = json.generate "${name}" value;
#         onChange = "${pkgs.systemd}/bin/systemctl --user try-restart ${service}";
#       };
#     })
#     config;
# in
{
  xdg.configFile = {
    "wireplumber/config/bluetooth.lua.d/50-bluez-config.lua" = {
      text = ''
        bluez_monitor.enabled = true
        
        rule = {
          matches = {
            {
              { "device.name", "matches", "bluez_card.*" },
            },
          },
          apply_properties = {
             ["bluez5.auto-connect"] = "[ hfp_hf hsp_hs a2dp_sink ]",
          },
        }
        
        table.insert(bluez_monitor.rules,rule)
        
        bluez_monitor.properties = {
           ["bluez5.enable-msbc"] = true,
           ["bluez5.enable-sbc-xq"] = true,
           ["bluez5.enable-hw-volume"] = true,
           ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
           ["bluez5.codecs"] = "[ sbc sbc_xq aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex faststream faststream_duplex ]",
        }
      '';
      onChange = "${pkgs.systemd}/bin/systemctl --user try-restart wireplumber";
    };
  };
  # // mapToFiles "pipewire" "pipewire/pipewire.conf.d" {
  #   "99-input-denoising.conf" = {
  #     "context.modules" = [
  #       {
  #         name = "libpipewire-module-filter-chain";
  #         args = {
  #           "node.description" = "Noise Canceling source";
  #           "media.name" = "Noise Canceling source";
  #           "filter.graph" = {
  #             nodes = [{
  #               type = "ladspa";
  #               name = "rnnoise";
  #               plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
  #               label = "noise_suppressor_mono";
  #               control = {
  #                 "VAD Threshold (%)" = 50.0;
  #                 "VAD Grace Period (ms)" = 200;
  #                 "Retroactive VAD Grace (ms)" = 0;
  #               };
  #             }];
  #           };
  #           "capture.props" = {
  #             "node.name" = "capture.rnnoise_source";
  #             "node.passive" = true;
  #           };
  #           "playback.props" = {
  #             "node.name" = "rnnoise_source";
  #             "media.class" = "Audio/Source";
  #           };
  #         };
  #       }
  #     ];
  #   };
  # };
}
