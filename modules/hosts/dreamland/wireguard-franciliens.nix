{
  den.aspects.wireguard-franciliens = {key}: {
    nixos = {config, ...}: {
      networking.wg-quick.interfaces.wg-franciliens = {
        privateKeyFile = key config;

        address = [
          "79.143.250.43/32"
          "2001:678:938:3ff::43/128"
        ];

        dns = [
          "2001:678:938::53:1"
          "2001:678:938::53:2"
          "79.143.250.1"
          "79.143.250.2"
        ];

        peers = [
          {
            publicKey = "Ybfh3twyBpj7wx/lo9AVBsBKNAUMSQqAWWV0LfywSDI=";
            endpoint = "stephanie.franciliens.net:51820";

            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
          }
        ];
      };
    };
  };
}
