{ flake, config, pkgs, lib, ...}:
{
  config = {
    services.paperless = {
      enable = true;
      address = "10.172.50.136";
      port = 58080;
      passwordFile = "/run/agenix/paperless/admin-pass";
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_URL = "https://paperless.kleen.org";
        PAPERLESS_CONSUMER_RECURSIVE = "true";
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = "true";
        PAPERLESS_CONSUMER_ENABLE_BARCODES = "true";
      };
    };
    systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
    systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
    systemd.services.paperless-web.after = ["var-lib-paperless.mount"];

    age.secrets."paperless/admin-pass" = {
      file = ../../secrets/paperless/admin-pass.age;
      mode = "0400";
    };

    age.secrets."paperless/secret-key" = {
      file = ../../secrets/paperless/secret-key.age;
      mode = "0400";
    };

    systemd.services.paperless-copy-secret = {
      requiredBy = [ "paperless-scheduler.service" ];
      before = [ "paperless-scheduler.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.coreutils}/bin/install --mode 400 --owner '${config.services.paperless.user}' --compare \
            /run/agenix/paperless/secret-key '${config.services.paperless.dataDir}/secret-key'
        '';
        Type = "oneshot";
      };
    };

    systemd.services.paperless-scheduler.script = lib.mkBefore ''
      export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
    '';
    systemd.services.paperless-consumer.script = lib.mkBefore ''
      export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
    '';
    systemd.services.paperless-web.script = lib.mkBefore ''
      export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
    '';

    fileSystems."/var/lib/paperless" = {
      device = "/persist/paperless";
      options = [ "bind" ];
    };
  };
}
