{ pkgs, ... }:
let
  knownHostsFile = pkgs.writeText "known_hosts" ''
    rsync ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEYEyoL8HADxd4D1md7t2LGcM8nNhShc5qCjttVH1vTg
  '';
in {
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
      paths = [ "/srv/rmfakecloud" ];
      doInit = true;
      repo = "11414@ch-s011.rsync.net:rmfakecloud";
      dateFormat = "-u +%s";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${pkgs.coreutils}/bin/head -c-1 /run/agenix/boron-borg";
      };
      environment = { BORG_RSH = "ssh -oBatchMode=yes -oIdentitiesOnly=yes -oUserKnownHostsFile=${knownHostsFile} -oHostKeyAlias=rsync -i /run/agenix/rsync"; };
      compression = "auto,lzma";
      startAt = "hourly";
    };

    "paperless-rsync.net" = {
      paths = [ "/persist/paperless" ];
      doInit = true;
      repo = "11414@ch-s011.rsync.net:paperless";
      dateFormat = "-u +%s";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${pkgs.coreutils}/bin/head -c-1 /run/agenix/boron-borg";
      };
      environment = { BORG_RSH = "ssh -oBatchMode=yes -oIdentitiesOnly=yes -oUserKnownHostsFile=${knownHostsFile} -oHostKeyAlias=rsync -i /run/agenix/rsync"; };
      compression = "auto,lzma";
      startAt = "hourly";
    };

    "radicale-rsync.net" = {
      paths = [ "/persist/radicale" ];
      doInit = true;
      repo = "11414@ch-s011.rsync.net:radicale";
      dateFormat = "-u +%s";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${pkgs.coreutils}/bin/head -c-1 /run/agenix/boron-borg";
      };
      environment = { BORG_RSH = "ssh -oBatchMode=yes -oIdentitiesOnly=yes -oUserKnownHostsFile=${knownHostsFile} -oHostKeyAlias=rsync -i /run/agenix/rsync"; };
      compression = "auto,lzma";
      startAt = "hourly";
    };
  };
}
