{ config, pkgs, nixosConfig, lib, ... }:
let
  workingDir = "${config.home.homeDirectory}/mail/tweag";

  syncScript = pkgs.writeShellScript "lieer-sync" ''
    ${lib.getExe pkgs.lieer} sync --quiet
    ${lib.getExe pkgs.notmuch} tag +tweag 'path:tweag/**'
    ${lib.getExe pkgs.notmuch} tag -inbox 'tag:sent'
  '';
in
{
  systemd.user.services.gmi = {
    Unit = {
      Description = "Sync GMail";
      ConditionPathExists = "${workingDir}/.gmailieer.json";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${syncScript}";
      WorkingDirectory = "${workingDir}";
    };
  };
  systemd.user.timers.gmi = {
    Unit = {
      Description = "Sync GMail";
    };
    Timer = {
      OnCalendar = "*-*-* *:00/5:00";
      RandomizedDelaySec = 30;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
