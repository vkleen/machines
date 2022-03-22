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
