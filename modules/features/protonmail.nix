{
  den.aspects.protonmail.homeManager = {
    pkgs,
    config,
    ...
  }: {
    config = let
      # PSM Certificate Override Settings file
      # This is a generated file!  Do not edit.
      getProtonmailBridgeCert = pkgs.writeShellScriptBin "getProtonmailBridgeCert.sh" ''
        set -euo pipefail

        cert_dir="${config.xdg.dataHome}/certs"
        ${pkgs.coreutils}/bin/mkdir -p "$cert_dir"

        ${pkgs.netcat}/bin/nc -z -v 127.000.001 1143
        echo | ${pkgs.openssl}/bin/openssl s_client -starttls imap -connect 127.0.0.1:1143 2>/dev/null \
             | ${pkgs.openssl}/bin/openssl x509 > ${config.xdg.dataHome}/certs/protonmail.pem

        out_dir="${config.home.homeDirectory}/.thunderbird/main"
        out_file="$out_dir/cert_override.txt"
        ${pkgs.coreutils}/bin/mkdir -p "$out_dir"

        fingerprint="$(${pkgs.openssl}/bin/openssl x509 -fingerprint -sha256 -noout -in "$cert_dir/protonmail.pem" | ${pkgs.gawk}/bin/awk -F'=' '{print $2}')"

        tmp="$(${pkgs.coreutils}/bin/mktemp)"

        ${pkgs.coreutils}/bin/cat > "$tmp" <<EOF
        127.0.0.1:1143:	OID.2.16.840.1.101.3.4.2.1	''${fingerprint}
        127.0.0.1:1025:	OID.2.16.840.1.101.3.4.2.1	''${fingerprint}
        EOF

        ${pkgs.coreutils}/bin/install -m 600 "$tmp" "$out_file"
        ${pkgs.coreutils}/bin/rm -f "$tmp"
      '';
    in {
      # Protonmail-Bridge service
      systemd.user.services.protonmail-bridge = {
        Unit = {
          Description = "Protonmail SMTP/IMAP client";
          After = ["graphical-session.target" "network.target"];
          Wants = ["network.target"];
          PartOf = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
          ExecStart = "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window";
          Restart = "always";
        };

        Install.WantedBy = ["graphical-session.target"];
      };

      systemd.user.services.protonmail-bridge-cert = {
        Unit = {
          Description = "Protonmail SMTP/IMAP client certificate";
          Wants = ["protonmail-bridge.service"];
          After = ["protonmail-bridge.service"];
          PartOf = ["graphical-session.target"];
          StartLimitIntervalSec = "infinity";
          StartLimitBurst = 3;
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${getProtonmailBridgeCert}/bin/getProtonmailBridgeCert.sh";
          Restart = "on-failure";
          RestartSec = 15;
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
