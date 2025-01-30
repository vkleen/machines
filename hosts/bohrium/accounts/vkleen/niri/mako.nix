{ ... }:
{
  services.mako = {
    enable = true;
    maxVisible = -1;
    borderRadius = 10;
    icons = false;
    defaultTimeout = 6000;
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
