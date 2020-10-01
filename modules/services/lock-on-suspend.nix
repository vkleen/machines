{pkgs, ...}:

{
  systemd.services.lock-on-suspend = {
    description = "Lock sessions on suspend";
    before = [ "sleep.target" ];
    unitConfig = {
      StopWhenUnneeded = "true";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      ${pkgs.systemd}/bin/loginctl lock-sessions
      sleep 5
    '';
  };

  systemd.targets.sleep = {
    wants = [ "lock-on-suspend.service" ];
  };
}
