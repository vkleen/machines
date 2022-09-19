{ config, pkgs, nixos, lib, flake, ... }:
let 
  workingDir = "${config.home.homeDirectory}/mail/tweag";

  syncScript = pkgs.writeShellScript "lieer-sync" ''
    ${pkgs.lieer}/bin/gmi sync --quiet
    ${pkgs.notmuch}/bin/notmuch tag +tweag 'path:tweag/**'
    ${pkgs.notmuch}/bin/notmuch tag -inbox 'tag:sent'
  '';
in {
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
