{ pkgs, ... }:
{
  age.secrets."rsync" = {
    file = ../../secrets/rsync.age;
    owner = "root";
  };
  age.secrets."boron-borg" = {
    file = ../../secrets/boron-borg.age;
    owner = "root";
  };
  services.borgbackup.jobs = {
    "rmfakecloud-rsync.net" = {
      paths = [ "/var/lib/rmfakecloud" ];
      doInit = true;
      repo = "11414@ch-s011.rsync.net:rmfakecloud";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${pkgs.coreutils}/bin/head -c-1 /run/secrets/boron-borg";
      };
      environment = { BORG_RSH = "ssh -oBatchMode=yes -oIdentitiesOnly=yes -i /run/secrets/rsync"; };
      compression = "auto,lzma";
      startAt = "hourly";
    };
  };
}
