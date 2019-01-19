{config, pkgs, ...}:
{
  systemd.nspawn = {
    "matlab" = {
      enable = true;
      execConfig = {
        Boot = true;
	PrivateUsers = "0";
      };
      filesConfig = {
	Bind = [
	  "/tmp/.X11-unix"
	  "/home/vkleen/matlab:/opt/matlab"
	  "/home/vkleen"
	];
	BindReadOnly = "/dev/dri";
	PrivateUsersChown = true;
      };
      networkConfig = {
      };
    };

    "arch" = {
      enable = true;
      execConfig = {
        Boot = true;
        PrivateUsers = "0";
      };
      filesConfig = {
        Bind = [
          "/tmp/.X11-unix"
          "/home/vkleen/arch:/home/vkleen"
        ];
        BindReadOnly = "/dev/dri";
        PrivateUsersChown = true;
      };
      networkConfig = {
        VirtualEthernet = false;
      };
    };
  };
}
