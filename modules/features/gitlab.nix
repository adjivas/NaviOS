{
  den.aspects.gitlab.nixos = {
    config,
    lib,
    ...
  }: {
    options.gitlab = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "gitlab.local";
        description = "Public hostname of the GitLab instance.";
      };

      statePath = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/gitlab";
        description = "Persistent GitLab state directory.";
      };

      secrets = {
        initialRootPasswordFile = lib.mkOption {
          type = lib.types.path;
          description = "File containing the initial GitLab root password.";
          example = config.age.secrets."gitlab/initial-root-password".path;
        };

        databasePasswordFile = lib.mkOption {
          type = lib.types.path;
          description = "File containing the GitLab PostgreSQL password.";
          example = config.age.secrets."gitlab/database-password".path;
        };

        secretFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab Rails secret key file.";
          example = config.age.secrets."gitlab/secret".path;
        };

        otpFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab OTP encryption secret file.";
          example = config.age.secrets."gitlab/otp-secret".path;
        };

        dbFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab database encryption secret file.";
          example = config.age.secrets."gitlab/db-secret".path;
        };

        jwsFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab JWS private key file.";
          example = config.age.secrets."gitlab/jws.pem".path;
        };

        activeRecordPrimaryKeyFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab Active Record primary encryption key file.";
          example = config.age.secrets."gitlab/active-record-primary-key".path;
        };

        activeRecordDeterministicKeyFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab Active Record deterministic encryption key file.";
          example = config.age.secrets."gitlab/active-record-deterministic-key".path;
        };

        activeRecordSaltFile = lib.mkOption {
          type = lib.types.path;
          description = "GitLab Active Record encryption salt file.";
          example = config.age.secrets."gitlab/active-record-salt".path;
        };
      };
    };

    config = {
      services.gitlab = {
        enable = true;
        host = "gitlab.local";
        port = 80;
        https = false;
        # host = config.gitlab.host;
        # port = 443;
        # https = true;
        statePath = config.gitlab.statePath;

        initialRootPasswordFile = config.gitlab.secrets.initialRootPasswordFile;
        databasePasswordFile = config.gitlab.secrets.databasePasswordFile;

        secrets = {
          secretFile = config.gitlab.secrets.secretFile;
          otpFile = config.gitlab.secrets.otpFile;
          dbFile = config.gitlab.secrets.dbFile;
          jwsFile = config.gitlab.secrets.jwsFile;
          activeRecordPrimaryKeyFile = config.gitlab.secrets.activeRecordPrimaryKeyFile;
          activeRecordDeterministicKeyFile = config.gitlab.secrets.activeRecordDeterministicKeyFile;
          activeRecordSaltFile = config.gitlab.secrets.activeRecordSaltFile;
        };

        backup = {
          startAt = "03:00";
          keepTime = 24 * 7;
        };
      };

      services.nginx = {
        enable = true;

        virtualHosts."gitlab.local" = {
          locations."/" = {
            proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
