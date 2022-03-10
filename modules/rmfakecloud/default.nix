{config, pkgs, lib, ...}:
let 
  cfg = config.services.rmfakecloud;
in {
  disabledModules = [ "services/misc/rmfakecloud.nix" ];
  options = {
    services.rmfakecloud = {
      enable = lib.mkEnableOption "rmfakecloud";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.rmfakecloud;
        defaultText = "pkgs.rmfakecloud";
        description = "rmfakecloud package";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to automatically open the specified port in the firewall.";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 3000;
        description = "rmfakecloud port";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 420;
        description = "rmfakecloud user id";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 420;
        description = "rmfakecloud group id";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/rmfakecloud";
        description = "rmfakecloud data directory";
      };
      storageUrl = lib.mkOption {
        type = lib.types.str;
        description = "Storage URL resolvable from the device";
      };
      logLevel = lib.mkOption {
        type = lib.types.enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "rmfakecloud log level";
      };
      jwtKey = lib.mkOption {
        type = lib.types.path;
        description = "file containing rmfakecloud JWT secret key";
      };
      hwrAppKey = lib.mkOption {
        type = lib.types.path;
        description = "file containing myScript app key";
      };
      hwrHMAC = lib.mkOption {
        type = lib.types.path;
        description = "file containing myScript HMAC";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.groups.rmfakecloud.gid = cfg.gid;
      users.users.rmfakecloud = {
        description = "rmfakecloud daemon user";
        uid = cfg.uid;
        group = "rmfakecloud";
      };
      networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
      systemd.services.rmfakecloud = {
        environment = {
          DATADIR = cfg.dataDir;
          STORAGE_URL = cfg.storageUrl;
          LOGLEVEL = cfg.logLevel;
          PORT = builtins.toString cfg.port;
        };
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        script = ''
          export JWT_SECRET_KEY=$(cat "''${CREDENTIALS_DIRECTORY}"/jwtKey)
          export RMAPI_HWR_APPLICATIONKEY=$(cat "''${CREDENTIALS_DIRECTORY}"/hwrAppKey)
          export RMAPI_HWR_HMAC=$(cat "''${CREDENTIALS_DIRECTORY}"/hwrHMAC)
          exec ${cfg.package}/bin/rmfakecloud
        '';
        serviceConfig = {
          User = "rmfakecloud";
          Restart = "always";
          Type = "simple";
          WorkingDirectory = cfg.dataDir;
          ReadWritePaths = cfg.dataDir;

          LoadCredential = [
            "jwtKey:${cfg.jwtKey}"
            "hwrAppKey:${cfg.hwrAppKey}"
            "hwrHMAC:${cfg.hwrHMAC}"
          ];

          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          KeyringMode = "private";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = "AF_INET AF_INET6";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SecureBits = "no-setuid-fixup-locked noroot-locked";
          SystemCallFilter = "@system-service";
          SystemCallArchitectures = "native";
        };
      };
    })
  ];
}
