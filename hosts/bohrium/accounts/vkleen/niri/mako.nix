{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      icons = false;
      default-timeout = 6000;
      border-radius = 10;
      max-visible = -1;
    };
    extraConfig = ''
      [urgency=low]
      default-timeout=4000

      [urgency=normal]
      default-timeout=6000

      [urgency=high]
      default-timeout=8000

      [app-name=Element]
      ignore-timeout=1
      default-timeout=0
    '';
  };
}
