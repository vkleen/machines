{ lib, ... }:
{
  config = {
    services.power-profiles-daemon.enable = true;
    services.tlp.enable = lib.mkForce false;

    services.logind = {
      settings.Login = {
        HandleLidSwitch = "lock";
        HandlePowerKey = "suspend";
        HandleHibernateKey = "ignore";
        HandleSuspendKey = "ignore";
        LidSwitchIgnoreInhibited = "no";
      };
    };
    services.upower.enable = true;
  };
}
