{
  den.aspects.tls.nixos = {
    lib,
    pkgs,
    config,
    ...
  }: {
    # openssl req -x509 -newkey rsa:4096 -nodes   -keyout dreamland-root-ca.key   -out dreamland-root-ca.crt   -days 3650   -subj "/CN=dreamland-root-ca"   -addext "basicConstraints=critical,CA:TRUE"   -addext "keyUsage=critical,keyCertSign,cRLSign"
    options.tls = {
      rootCaKey = lib.mkOption {
        type = lib.types.path;
        description = "Path to the root CA private key (root-ca.key).";
      };

      rootCaCrt = lib.mkOption {
        type = lib.types.path;
        description = "Path to the root CA certificate (root-ca.crt).";
      };

      serverCertGroup = lib.mkOption {
        type = lib.types.str;
        description = "Group allowed to read generated TLS certificates.";
      };

      serverCertDirectoryMode = lib.mkOption {
        type = lib.types.str;
        default = "0750";
        description = "Mode for the TLS certificate directory.";
      };

      serverCertDirectory = lib.mkOption {
        type = lib.types.path;
        description = ''
          Directory where this module will generate:
          - server-ca.key
          - server-ca.crt
        '';
      };

      serverCommonName = lib.mkOption {
        type = lib.types.str;
        description = "Server certificate common name (e.g. dreamland.local).";
      };

      serverIpAddress = lib.mkOption {
        type = lib.types.str;
        description = "Server IP address included in certificate SANs (e.g. 127.0.0.1).";
      };
      serverCertificateDays = lib.mkOption {
        type = lib.types.int;
        default = 3650;
        description = ''
          Number of days the generated server certificate remains valid.
        '';
      };
    };
    config = {
      system.activationScripts.certificate.text = ''
        set -eu

        dst="${config.tls.serverCertDirectory}"
        name="${config.networking.hostName}"
        group="${config.tls.serverCertGroup}"

        install -d -m ${config.tls.serverCertDirectoryMode} -o root -g "$group" "$dst"

        if [ ! -f "$dst/$name.key" ]; then
          ${pkgs.openssl}/bin/openssl genrsa \
            -out "$dst/$name.key" \
            4096
        fi

        chown root:"$group" "$dst/$name.key"
        chmod 0640 "$dst/$name.key"

        csr="$(mktemp)"
        tmp_crt="$(mktemp)"
        ext="$(mktemp)"

        trap 'rm -f "$csr" "$ext" "$tmp_crt"' EXIT

        ${pkgs.openssl}/bin/openssl req \
         -new \
         -key "$dst/$name.key" \
         -out "$csr" \
         -subj "/CN=${config.tls.serverCommonName}"

        printf '%s\n' \
          'basicConstraints=critical,CA:FALSE' \
          'keyUsage=critical,digitalSignature,keyEncipherment' \
          'extendedKeyUsage=serverAuth' \
          'subjectAltName=DNS:${config.tls.serverCommonName},DNS:localhost,IP:${config.tls.serverIpAddress}' \
          > "$ext"

        ${pkgs.openssl}/bin/openssl x509 \
          -req \
          -in "$csr" \
          -CA "${config.tls.rootCaCrt}" \
          -CAkey "${config.tls.rootCaKey}" \
          -set_serial "$(date +%s%N)" \
          -out "$tmp_crt" \
          -days ${toString config.tls.serverCertificateDays} \
          -sha256 \
          -extfile "$ext"

        install -m 0640 -o root -g "$group" "$tmp_crt" "$dst/$name.crt"
        chmod 0640 "$dst/$name.key" "$dst/$name.crt"
      '';
    };
  };
}
