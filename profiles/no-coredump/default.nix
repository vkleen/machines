{ ... }:
{
  systemd.coredump.extraConfig = ''
    Storage=none
    ProcessSizeMax=0
  '';
}
