{ config, pkgs, ...}:
{
  services = {
    redsocks = {
      enable = true;
      redsocks = [
        { port = 3334;
          proxy = "127.0.0.1:3333";
          type = "socks5";
          redirectCondition = "-d 188.68.51.254";
        }
      ];
    };
    autossh = {
      sessions = [
        { name = "socks-amy";
	  user = "vkleen";
	  monitoringPort = 0;
	  extraArguments = "-N -D3333 amy-proxy";
	}
      ];
    };
  };
}
