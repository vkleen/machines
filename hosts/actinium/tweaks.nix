{ ... }:
{
  systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";
}
